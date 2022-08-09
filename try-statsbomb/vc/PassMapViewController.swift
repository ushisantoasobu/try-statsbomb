//
//  PassMapViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/20.
//

import Foundation
import UIKit

class PassMapViewController: UIViewController {

    var competition: Competition!
    var match: Match!
    var isHome: Bool!

    static func instantiate(
        competition: Competition,
        match: Match,
        isHome: Bool
    ) -> PassMapViewController {
        let vc = PassMapViewController()
        vc.competition = competition
        vc.match = match
        vc.isHome = isHome
        return vc
    }

    let passMapDrawView = PassMapDrawView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(passMapDrawView)

        setupCloseButtonOnNav()
        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passMapDrawView.frame = view.frame

        setup()
    }

    func setup() {

        let dataFetcher = DataFetcher()
        Task {
            do {
                let game: Game = try await dataFetcher.fetch(id: match.id)

                let converter = TwoPlayersPassListConverer()
                converter.setup(events: game.events)
                var _twoPlayersPassList: [Set<Player.ID>: Int] = [:]
                converter.list.forEach { sender, receiver in
                    let combination: Set<Player.ID> = [sender, receiver]
                    if let count = _twoPlayersPassList[combination] {
                        _twoPlayersPassList[combination] = count + 1
                    } else {
                        _twoPlayersPassList[combination] = 1
                    }
                }
                let twoPlayersPassList = _twoPlayersPassList

                await MainActor.run {
                    var some: [Player.ID: CGPoint] = [:]

                    game.lineups[isHome ? 0 : 1]
                        .lineup
                        .filter { $0.isStartingMember }
                        .forEach { lineup in

                            // プレーヤーの表示
                            let playerView = BasicPlayerView(
                                frame: .init(x: 0, y: 0, width: 10, height: 10)
                            )
                            let point = PositionToViewConverter()
                                .convert(positionId: lineup.startingPosition!.positionId)
                            some[lineup.playerId] = point
                            playerView.center = .init(
                                x: view.frame.size.width * point.x,
                                y: view.frame.size.height * (1 - point.y)
                            )
                            playerView.player = lineup
                            view.addSubview(playerView)
                    }

                    // パスマップ描画
                    let _some = some
                    passMapDrawView.list = twoPlayersPassList
                        .filter { playerIds, _ in
                            _some.keys.contains(Array(playerIds)[0]) &&
                            _some.keys.contains(Array(playerIds)[1])
                        }
                        .map({ playerIds, passCount in
                        return (
                            firstPlayerPoint: some[Array(playerIds)[0]]!,
                            secondPlayerPoint: some[Array(playerIds)[1]]!,
                            passCount: passCount
                        )
                    })
                    passMapDrawView.setNeedsDisplay()
                }

            } catch {
                print(error)
                fatalError("error")
            }
        }
    }
}

fileprivate class TwoPlayersPassListConverer {

    private (set) var list: [(sender: Player.ID, receiver: Player.ID)] = []

    func setup(events: [Event]) {
        list = []

        events
            .filter { $0.pass != nil }
            .map { ($0.pass!, $0.player!) }
            .forEach { data in
            let sender = data.1
            if let recipient = data.0.recipient {
                let receiver = recipient
                list.append((sender: sender.id, receiver: receiver.id))
            }
        }
    }
}

class PassMapDrawView: UIView {

    var list: [(firstPlayerPoint: CGPoint, secondPlayerPoint: CGPoint, passCount: Int)] = [] {
        didSet {
            print(list)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        list.forEach {
            let line = UIBezierPath()
            line.move(
                to: .init(
                    x: frame.width * $0.firstPlayerPoint.x,
                    y: frame.height * (1 - $0.firstPlayerPoint.y)
                )
            )
            line.addLine(
                to: .init(
                    x: frame.width * $0.secondPlayerPoint.x,
                    y: frame.height * (1 - $0.secondPlayerPoint.y)
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat($0.passCount / 2)
            line.stroke()
        }
    }
}
