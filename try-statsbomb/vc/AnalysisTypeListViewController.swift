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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let alert = UIAlertController(
            title: "洗濯してください",
            message: nil,
            preferredStyle: .actionSheet
        )
        let home = UIAlertAction(
            title: "ホームチーム",
            style: .default) { [unowned self] _ in
                selected(item: Item(rawValue: indexPath.row)!, isHome: true)
            }
        let away = UIAlertAction(
            title: "アウェイチーム",
            style: .default) { [unowned self] _ in
                selected(item: Item(rawValue: indexPath.row)!, isHome: false)
            }
        let cancel = UIAlertAction(
            title: "キャンセル",
            style: .cancel,
            handler: nil)
        alert.addAction(home)
        alert.addAction(away)
        alert.addAction(cancel)

        if let selectedCell = tableView.cellForRow(at: indexPath) {
            alert.popoverPresentationController?.sourceView = selectedCell
            alert.popoverPresentationController?.sourceRect = selectedCell.frame
        } else {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.frame
        }

        present(alert, animated: true, completion: nil)
    }

    private func selected(item: Item, isHome: Bool) {
        switch item {
        case .passSonar:
            let vc = PassSonarViewController.instantiate(
                competition: competition,
                match: match,
                isHome: isHome
            )
            present(vc, animated: true)
        case .passMap:
            let vc = PassMapViewController.instantiate(
                competition: competition,
                match: match,
                isHome: isHome
            )
            present(vc, animated: true)
        case .playground:
            break
        }
    }
}
