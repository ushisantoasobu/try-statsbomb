//
//  CompetitionListViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/01.
//

import UIKit

class CompetitionListViewController: UITableViewController {

    var list: [Competition] = []
    let fetcher = DataFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Competitions"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        Task {
            do {
                self.list = try await fetcher.fetchCompetitions()
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
        cell.textLabel?.text = list[indexPath.row].name + " / " + list[indexPath.row].season
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        print(list[indexPath.row])

        let vc = MatchListViewController(competition: list[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
