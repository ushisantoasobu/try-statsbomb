//
//  PassSonarViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/20.
//

import Foundation
import UIKit

class PassSonarViewController: UIViewController {

    var competition: Competition!
    var match: Match!
    var isHome: Bool!

    static func instantiate(
        competition: Competition,
        match: Match,
        isHome: Bool
    ) -> PassSonarViewController {
        let vc = PassSonarViewController()
        vc.competition = competition
        vc.match = match
        vc.isHome = isHome
        return vc
    }

//    init(competition: Competition, match: Match, isHome: Bool) {
//        self.competition = competition
//        self.match = match
//        self.isHome = isHome
//
//        super.init()
//    }
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        fatalError()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupCloseButtonOnNav()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setup()
    }

    func setup() {
        let dataFetcher = DataFetcher()
        Task {
            do {
                let game: Game = try await dataFetcher.fetch(id: match.id)
                let passListConverter = PassListConverter()
                passListConverter.setup(events: game.events)
                let playerAndPasses = passListConverter.dic

                await MainActor.run {
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
                            playerView.center = .init(
                                x: view.frame.size.width * point.x,
                                y: view.frame.size.height * (1 - point.y)
                            )
                            playerView.player = lineup
                            view.addSubview(playerView)

                            // パスソナー表示
                            let passSonarView = PassSonarView(
                                frame: .init(x: 0, y: 0, width: 500, height: 500)
                            )
                            passSonarView.center = .init(
                                x: view.frame.size.width * point.x,
                                y: view.frame.size.height * (1 - point.y)
                            )
                            passSonarView.passes = playerAndPasses[lineup.playerId] ?? []
                            view.addSubview(passSonarView)
                    }
                }

            } catch {
                print(error)
                fatalError("error")
            }
        }
    }
}

fileprivate class PassSonarView: UIView {

    var name: String = ""
    var passes: [Pass] = []

    var nameLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        nameLabel = UILabel(frame: .zero)
        addSubview(nameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        nameLabel.text = name
        nameLabel.frame = .init(
            x: frame.size.width * 0.5,
            y: frame.size.height * 0.5,
            width: 0,
            height: 0
        )
        nameLabel.sizeToFit()

        passes
            .filter { $0.type == nil }
            .forEach { pass in
            let angle = pass.angle
//            print(angle)
//            let length: Double = 100 // 一旦固定

            let line = UIBezierPath()
            line.move(to: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2))
            // 下の length * xxx は補正値
            let adjustment: CGFloat = 4
            let x: Double = (pass.length * adjustment) * cos(angle - CGFloat.pi * 0.5)
            let y: Double = (pass.length * adjustment) * sin(angle - CGFloat.pi * 0.5)

            line.addLine(
                to:CGPoint(
                    x: frame.size.width * 0.5 + x,
                    y: frame.size.height * 0.5 + y
                )
            )
            line.close()
            let color = UIColor.gray.withAlphaComponent(0.5)
            color.setStroke()
            line.lineWidth = 1
            line.stroke()
        }
    }
}

fileprivate class PassListConverter {
    // playerId: PassList
    var dic: [Player.ID: [Pass]] = [:]

    func setup(events: [Event]) {
        let playerAndPassList: [(player: Player, pass: Pass)] = events
            .filter { $0.pass != nil }
            .map { ($0.player!, $0.pass!) }

        playerAndPassList.forEach { playerAndPass in
            if dic[playerAndPass.player.id] == nil {
                dic[playerAndPass.player.id] = [playerAndPass.pass]
            } else {
                var passes = dic[playerAndPass.player.id]
                passes?.append(playerAndPass.pass)
                dic[playerAndPass.player.id] = passes
            }
        }
    }
}
