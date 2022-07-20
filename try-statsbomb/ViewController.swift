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

        var title: String {
            switch self {
            case .passSonar:
                return "パスソナーもどき"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            let vc = PassSonarViewController()
            present(vc, animated: true)
        }
    }
}

class PassSonarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    func setup() {

        let manager = PassRecordManager()

        guard let jsonFilePath = Bundle.main.url(forResource: "18236", withExtension: "json") else {
            fatalError("not found json file")
        }

        guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
            fatalError("failed to load json file")
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let events = try decoder.decode([Event].self, from: jsonData)
            print(events.count)
            let passAndPlayerList: [(Pass, Player)] = events.filter { $0.pass != nil }.map { ($0.pass!, $0.player!) }
//            print(passes)

            manager.setup(passAndPlayerList: passAndPlayerList)
            print(manager.countList)

        } catch {
            print(error)
        }

        let barca_1 = manager.passes.filter { $0.key.name.contains("Víctor") }.first!
        let barca_2 = manager.passes.filter { $0.key.name.contains("Gerard") }.first!
        let barca_3 = manager.passes.filter { $0.key.name.contains("Puyol") }.first!
        let barca_4 = manager.passes.filter { $0.key.name.contains("Abidal") }.first!
        let barca_5 = manager.passes.filter { $0.key.name.contains("Daniel") }.first!
        let barca_6 = manager.passes.filter { $0.key.name.contains("Busquets") }.first!
        let barca_7 = manager.passes.filter { $0.key.name.contains("Iniesta") }.first!
        let barca_8 = manager.passes.filter { $0.key.name.contains("Xavier") }.first!
        let barca_9 = manager.passes.filter { $0.key.name.contains("Pedro") }.first!
        let barca_10 = manager.passes.filter { $0.key.name.contains("Villa") }.first!
        let barca_11 = manager.passes.filter { $0.key.name.contains("Messi") }.first!

        let barcaPlayerList = [
            barca_1,
            barca_2,
            barca_3,
            barca_4,
            barca_5,
            barca_6,
            barca_7,
            barca_8,
            barca_9,
            barca_10,
            barca_11
        ]

        let calclator = PlayerPosCalculator()
        barcaPlayerList.enumerated().forEach { aaa in
            let some = PassSonarView()
            let size: CGFloat = 500
            print("@@@@@ size: \(view.frame.size)")
            let point = try! calclator.execute(formation: .f4123, index: aaa.offset, size: view.frame.size)
            some.frame = .init(
                x: point.x - size * 0.5,
                y: point.y - size * 0.5,
                width: size,
                height: size
            )
            some.passes = aaa.element.value
            some.name = aaa.element.key.name
            view.addSubview(some)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setup()
    }
}

class PassSonarView: UIView {

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
            let adjustment: CGFloat = 2
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

class PassRecordManager {

    private var dic: [Player: [Pass]] = [:]

    var passes: [Player: [Pass]] {
        dic
    }

    var countList: [(Player, Int)] {
        return dic.map { key, value in
            (key, value.count)
        }
    }

    func setup(passAndPlayerList: [(Pass, Player)]) {
        dic = [:]

        passAndPlayerList.forEach { data in
            if dic[data.1] == nil {
                dic[data.1] = [data.0]
            } else {
                var passes = dic[data.1]
                passes?.append(data.0)
                dic[data.1] = passes
            }
        }
    }
}

enum Formation {
    case f4123
}

struct PlayerPosCalculator {

    func execute(formation: Formation, index: Int, size: CGSize) throws -> CGPoint {
        switch formation {
        case .f4123:
            let list: [CGPoint] = [
                .init(x: size.width * 0.5, y: size.height * 0.9),
                .init(x: size.width * 0.35, y: size.height * 0.75),
                .init(x: size.width * 0.65, y: size.height * 0.75),
                .init(x: size.width * 0.1, y: size.height * 0.65),
                .init(x: size.width * 0.9, y: size.height * 0.65),
                .init(x: size.width * 0.5, y: size.height * 0.6),
                .init(x: size.width * 0.35, y: size.height * 0.5),
                .init(x: size.width * 0.65, y: size.height * 0.5),
                .init(x: size.width * 0.1, y: size.height * 0.35),
                .init(x: size.width * 0.9, y: size.height * 0.35),
                .init(x: size.width * 0.5, y: size.height * 0.25)
            ]
            return list[index]
        }
    }
}
