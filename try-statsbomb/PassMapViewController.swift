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

            let barcaEvents = events.filter { $0.team?.id == 217 }

            let passAndPlayerList: [(Pass, Player)] = barcaEvents
                .filter { $0.pass != nil }
                .map { ($0.pass!, $0.player!) }
            manager.setup(passAndPlayerList: passAndPlayerList)
            print("list is: \(manager.list)")

        } catch {
            print(error)
        }

        var hoge: [Set<Player>: Int] = [:]
        manager.list
            .forEach { send, receive in
            let combination: Set<Player> = [send, receive]
            if let count = hoge[combination] {
                hoge[combination] = count + 1
            } else {
                hoge[combination] = 1
            }
        }
        print(hoge)

        passMapDrawView.hoge = hoge
        passMapDrawView.setNeedsDisplay()

//        let calclator = PlayerPosCalculator()
//        hoge.forEach { (players, passCount) in
//            let first = Array(players)[0]
//            let second = Array(players)[1]
//
//            guard let firstIndex = detectIndex(player: first),
//               let secondIndex = detectIndex(player: second) else {
//                   return
//            }
//
//            let firstPoint = try! calclator.execute(formation: .f4123, index: firstIndex, size: view.frame.size)
//            let secondPoint = try! calclator.execute(formation: .f4123, index: secondIndex, size: view.frame.size)
//
//            let line = UIBezierPath()
//            line.move(to: firstPoint)
//            line.addLine(to: secondPoint)
//            line.close()
//            UIColor.gray.setStroke()
//            line.lineWidth = CGFloat(passCount / 2)
//            line.stroke()
//        }

//        let barca_1 = manager.passes.filter { $0.key.name.contains("Víctor") }.first!
//        let barca_2 = manager.passes.filter { $0.key.name.contains("Gerard") }.first!
//        let barca_3 = manager.passes.filter { $0.key.name.contains("Puyol") }.first!
//        let barca_4 = manager.passes.filter { $0.key.name.contains("Abidal") }.first!
//        let barca_5 = manager.passes.filter { $0.key.name.contains("Daniel") }.first!
//        let barca_6 = manager.passes.filter { $0.key.name.contains("Busquets") }.first!
//        let barca_7 = manager.passes.filter { $0.key.name.contains("Iniesta") }.first!
//        let barca_8 = manager.passes.filter { $0.key.name.contains("Xavier") }.first!
//        let barca_9 = manager.passes.filter { $0.key.name.contains("Pedro") }.first!
//        let barca_10 = manager.passes.filter { $0.key.name.contains("Villa") }.first!
//        let barca_11 = manager.passes.filter { $0.key.name.contains("Messi") }.first!
//
//        let barcaPlayerList = [
//            barca_1,
//            barca_2,
//            barca_3,
//            barca_4,
//            barca_5,
//            barca_6,
//            barca_7,
//            barca_8,
//            barca_9,
//            barca_10,
//            barca_11
//        ]
//
//        let calclator = PlayerPosCalculator()
//        barcaPlayerList.enumerated().forEach { aaa in
//            let some = PassSonarView()
//            let size: CGFloat = 500
//            print("@@@@@ size: \(view.frame.size)")
//            let point = try! calclator.execute(formation: .f4123, index: aaa.offset, size: view.frame.size)
//            some.frame = .init(
//                x: point.x - size * 0.5,
//                y: point.y - size * 0.5,
//                width: size,
//                height: size
//            )
//            some.passes = aaa.element.value
//            some.name = aaa.element.key.name
//            view.addSubview(some)
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passMapDrawView.frame = view.frame

        setup()
    }
}

fileprivate class PassRecordManager {

    private (set) var list: [(send: Player, receive: Player)] = []

    func setup(passAndPlayerList: [(Pass, Player)]) {
        list = []

        passAndPlayerList.forEach { data in
            let send = data.1
            if let recipient = data.0.recipient {
                let receive = recipient
                list.append((send: send, receive: receive))
            }
        }
    }
}

class PassMapDrawView: UIView {

    var hoge: [Set<Player>: Int] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let calclator = PlayerPosCalculator()
        hoge.forEach { (players, passCount) in
            let first = Array(players)[0]
            let second = Array(players)[1]

            guard let firstIndex = detectIndex(player: first),
               let secondIndex = detectIndex(player: second) else {
                   return
            }

            let firstPoint = try! calclator.execute(formation: .f4123, index: firstIndex, size: frame.size)
            let secondPoint = try! calclator.execute(formation: .f4123, index: secondIndex, size: frame.size)

            let line = UIBezierPath()
            line.move(to: firstPoint)
            line.addLine(to: secondPoint)
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat(passCount / 2)
            line.stroke()
        }
    }
}

fileprivate func detectIndex(player: Player) -> Int? {
    if player.name.contains("Víctor") { return 0 }
    if player.name.contains("Gerard") { return 1 }
    if player.name.contains("Puyol") { return 2 }
    if player.name.contains("Abidal") { return 3 }
    if player.name.contains("Daniel") { return 4 }
    if player.name.contains("Busquets") { return 5 }
    if player.name.contains("Iniesta") { return 6 }
    if player.name.contains("Xavier") { return 7 }
    if player.name.contains("Pedro") { return 8 }
    if player.name.contains("Villa") { return 9 }
    if player.name.contains("Messi") { return 10 }

    return nil
}
