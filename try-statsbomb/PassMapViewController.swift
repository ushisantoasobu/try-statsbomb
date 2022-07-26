//
//  PassMapViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/20.
//

import Foundation
import UIKit

class PassMapViewController: UIViewController {

    let passMapDrawView = PassMapDrawView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(passMapDrawView)

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
                let game: Game = try await dataFetcher.fetch(id: 3773387)

                let converter = TwoPlayersPassListConverer()
                converter.setup(events: game.events)
                var _twoPlayersPassList: [Set<Int>: Int] = [:]
                converter.list.forEach { sender, receiver in
                    let combination: Set<Int> = [sender, receiver]
                    if let count = _twoPlayersPassList[combination] {
                        _twoPlayersPassList[combination] = count + 1
                    } else {
                        _twoPlayersPassList[combination] = 1
                    }
                }
                let twoPlayersPassList = _twoPlayersPassList

                await MainActor.run {
                    var some: [Int: CGPoint] = [:]

                    game.lineups[1]
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
                                y: view.frame.size.height * point.y
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

    // playerId, playerId
    private (set) var list: [(sender: Int, receiver: Int)] = []

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
                    y: frame.height * $0.firstPlayerPoint.y
                )
            )
            line.addLine(
                to: .init(
                    x: frame.width * $0.secondPlayerPoint.x,
                    y: frame.height * $0.secondPlayerPoint.y
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat($0.passCount / 2)
            line.stroke()
        }
    }
}
