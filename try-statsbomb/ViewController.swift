//
//  ViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/16.
//

import UIKit

class ViewController: UITableViewController {

    enum Item: Int, CaseIterable {
        case passSonar
        case passMap
        case playground

        var title: String {
            switch self {
            case .passSonar:
                return "パスソナーもどき"
            case .passMap:
                return "パスマップもどき"
            case .playground:
                return "Playground"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "一覧"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        /*
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
            } catch {
                print(error)
                fatalError("error")
            }
        }
         */
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Item.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = Item(rawValue: indexPath.row)

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = item?.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let item = Item(rawValue: indexPath.row)!

        switch item {
        case .passSonar:
//            let vc = PassSonarViewController()
//            present(vc, animated: true)
            break
        case .passMap:
            let vc = PassMapViewController()
            present(vc, animated: true)
        case .playground:
            let vc = PlaygroundViewController()
            present(vc, animated: true)
        }
    }
}
