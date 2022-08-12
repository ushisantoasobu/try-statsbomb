//
//  MatchListViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/02.
//

import UIKit

class MatchListViewController: UITableViewController {

    let competition: Competition

    var list: [Match] = []
    let fetcher = DataFetcher()

    init(competition: Competition) {
        self.competition = competition

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Matches"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        Task {
            do {
                self.list = try await fetcher.fetchMatches(
                    competitionId: competition.id,
                    seasonId: competition.seasonId
                )
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // TODO: そろそろUITableViewCellの新しい書き方覚えないと
        let match = list[indexPath.row]
        cell.textLabel?.text = "\(match.homeTeam.name) \(match.homeScore)-\(match.awayScore) \(match.awayTeam.name)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        print(list[indexPath.row])

        let vc = AnalysisTypeListViewController(competition: competition, match: list[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
