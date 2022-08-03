//
//  AnalysisTypeListViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/04.
//

import UIKit

class AnalysisTypeListViewController: UITableViewController {

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

    let competition: Competition
    let match: Match

    init(competition: Competition, match: Match) {
        self.competition = competition
        self.match = match

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Analysis Types"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Item.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // TODO: そろそろUITableViewCellの新しい書き方覚えないと
        cell.textLabel?.text = Item.allCases[indexPath.row].title
        return cell
    }
}
