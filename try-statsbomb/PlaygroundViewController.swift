//
//  PlaygroundViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/22.
//

import Foundation
import UIKit

class PlaygroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setup()
    }

    func setup() {
        let dataFetcher = DataFetcher()
        Task {
            do {
                let game: Game = try await dataFetcher.fetch(id: 18236)
                game.lineups.forEach { team in
                    print("Team: \(team.teamName)")
                    team.lineup.filter { $0.isStartingMember }.forEach { lineup in
                        print("Player: \(lineup.playerName) - \(lineup.startingPosition?.position ?? "-")")
                    }
                }

                await MainActor.run {
                    game.lineups[0].lineup.filter { $0.isStartingMember }.forEach { lineup in
                        let playerView = BasicPlayerView(frame: .init(x: 0, y: 0, width: 10, height: 10))
                        let point = PositionToViewConverter().convert(positionId: lineup.startingPosition!.positionId)
                        playerView.center = .init(
                            x: view.frame.size.width * point.x,
                            y: view.frame.size.height * point.y
                        )
                        playerView.player = lineup
                        view.addSubview(playerView)
                    }
                }

            } catch {
                print(error)
                fatalError("error")
            }
        }
    }
}
