//
//  PossessionViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/13.
//

import UIKit

class PossessionViewController: UIViewController {

    static func instantiate(
        competition: Competition,
        match: Match
    ) -> PossessionViewController {
        let vc = PossessionViewController()
        vc.competition = competition
        vc.match = match
        return vc
    }

    var competition: Competition!
    var match: Match!

    let fetcher = DataFetcher()

    var possesionList: [Possession] = []
    var goalList: [Goal] = []

    var possessionStreamView: UIView!
    var homePossessionRateLabel: UILabel!
    var awayPossessionRateLabel: UILabel!

    struct Possession {
        let start: Double
        let end: Double
        let isHome: Bool
    }

    struct Goal {
        let time: Double
        let player: Player
        let isHome: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButtonOnNav()

        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            do {
                let game = try await fetcher.fetch(id: match.id)

//                let lineups = game.lineups[isHome ? 0 : 1].lineup

                var currentTeamId: Team.ID?
                var firstHalfLastTime: Double?

                game.events.forEach { event in
                    let possessionTeamId = event.possessionTeam.id
                    let isHome = possessionTeamId.rawValue == match.homeTeam.id.rawValue

                    if firstHalfLastTime == nil {
                        if event.period == 2 {
                            firstHalfLastTime = possesionList.last!.end
                        }
                    }

                    let now = event.period == 2 ? event.convertTimestampToSeconds() + firstHalfLastTime! : event.convertTimestampToSeconds()

                    if let _currentTeamId = currentTeamId {
                        if _currentTeamId == possessionTeamId {
                            let last = possesionList.removeLast()
                            possesionList.append(
                                Possession(
                                    start: last.start,
                                    end: now,
                                    isHome: last.isHome
                                )
                            )
                        } else {
                            let last = possesionList.removeLast()
                            possesionList.append(
                                Possession(
                                    start: last.start,
                                    end: now,
                                    isHome: last.isHome
                                )
                            )

                            possesionList.append(
                                Possession(
                                    start: now,
                                    end: now,
                                    isHome: isHome
                                )
                            )
                        }
                        currentTeamId = possessionTeamId
                    } else {
                        possesionList.append(
                            Possession(
                                start: now,
                                end: now,
                                isHome: isHome
                            )
                        )
                        currentTeamId = possessionTeamId
                    }

                    // goal
                    if let shot = event.shot {
                        // owngoalなどは別途考慮しないといけないぽい
                        // ref: https://github.com/statsbomb/open-data/issues/6
                        if shot.outcome.name == "Goal" {
                            goalList.append(
                                .init(
                                    time: now,
                                    player: event.player!,
                                    isHome: isHome
                                )
                            )
                        }
                    }
                }

                print(possesionList)

                let total = possesionList.last!.end

                // ポゼッションのストリームビューを描く
                possesionList.forEach { possession in
                    if possession.isHome {
                        let hoge = UIView(
                            frame: .init(
                                x: 0,
                                y: possession.start / total * view.frame.size.height,
                                width: view.frame.size.width * 0.5,
                                height: (possession.end - possession.start) / total * view.frame.size.height
                            )
                        )
                        hoge.backgroundColor = .blue
                        view.addSubview(hoge)
                    } else {
                        let hoge = UIView(
                            frame: .init(
                                x: view.frame.size.width * 0.5,
                                y: possession.start / total * view.frame.size.height,
                                width: view.frame.size.width * 0.5,
                                height: (possession.end - possession.start) / total * view.frame.size.height
                            )
                        )
                        hoge.backgroundColor = .red
                        view.addSubview(hoge)
                    }
                }

                // ポゼッション率のログを出す
                let homeResult = possesionList
                    .filter { $0.isHome }
                    .reduce(0) { result, possession in
                        result + (possession.end - possession.start)
                    }
                print("ホームチームの歩セッション率 \(homeResult / possesionList.last!.end)")

                // ゴール表記をする
                goalList.forEach { goal in
                    let label = UILabel(frame: .zero)
                    label.text = goal.player.name
                    label.backgroundColor = .white
                    label.sizeToFit()
                    view.addSubview(label)
                    let x = goal.isHome ? view.frame.size.width / 4 : view.frame.size.width * 3 / 4
                    label.center = .init(
                        x: x,
                        y: goal.time / total * view.frame.size.height
                    )
                }
                

            } catch {
                fatalError()
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
