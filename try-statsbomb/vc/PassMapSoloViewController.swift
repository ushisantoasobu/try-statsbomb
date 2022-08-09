//
//  PassMapSoloViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/07.
//

import UIKit

class PassMapSoloViewController: UIViewController {

    static func instantiate(
        competition: Competition,
        match: Match
    ) -> PassMapSoloViewController {
        let vc = PassMapSoloViewController()
        vc.competition = competition
        vc.match = match
        return vc
    }

    var competition: Competition!
    var match: Match!

    private var pageVC: UIPageViewController!
    private var homeVC: PassMapSoloEachViewController!
    private var awayVC: PassMapSoloEachViewController!

    fileprivate var vcs: [PassMapSoloEachViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButtonOnNav()
        navigationItem.title = "パスマップ（個人）"

        pageVC = .init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageVC.view)
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        addChild(pageVC)

        homeVC = PassMapSoloEachViewController.instantiate(
            competition: competition,
            match: match,
            isHome: true
        )
        awayVC = PassMapSoloEachViewController.instantiate(
            competition: competition,
            match: match,
            isHome: false
        )
        vcs = [homeVC, awayVC]

        pageVC.setViewControllers(
            [homeVC],
            direction: .forward,
            animated: true,
            completion: nil
        )

        pageVC.delegate = self
        pageVC.dataSource = self
    }
}

extension PassMapSoloViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        vcs.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == homeVC {
            return nil
        } else {
            return awayVC
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == homeVC {
            return awayVC
        } else {
            return nil
        }
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        0
    }
}

fileprivate class PassMapSoloEachViewController: UIViewController {

    var competition: Competition!
    var match: Match!
    var isHome: Bool!

    var homePlayerAndPassList: [Player: [Event]] = [:]
    var awayPlayerAndPassList: [Player: [Event]] = [:]

    var fieldView: UIView?
    private var playerSelectButton: UIButton!
    private var teamAndPlayerLabel: UILabel!
    private var passDrawingView: PassDrawingView!

    let fetcher = DataFetcher()

    static func instantiate(
        competition: Competition,
        match: Match,
        isHome: Bool
    ) -> PassMapSoloEachViewController {
        let vc = PassMapSoloEachViewController()
        vc.competition = competition
        vc.match = match
        vc.isHome = isHome
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white //isHome ? .red : .blue

        // setup player button
        playerSelectButton = UIButton(frame: .zero)
        playerSelectButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        playerSelectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerSelectButton)

        playerSelectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        playerSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        playerSelectButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        playerSelectButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // setup label
        teamAndPlayerLabel = UILabel(frame: .zero)
        teamAndPlayerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        teamAndPlayerLabel.text = isHome ? "Home Team" : "Away Team"

        teamAndPlayerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(teamAndPlayerLabel)

        teamAndPlayerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        teamAndPlayerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
    }

    override func viewDidLayoutSubviews() {
        if fieldView == nil {
            drawField()

            passDrawingView = PassDrawingView.init(frame: .zero)
            passDrawingView.frame = fieldView!.bounds
            fieldView!.addSubview(passDrawingView)

            Task {
                do {
                    let game = try await fetcher.fetch(id: match.id)
                    game.events
                        .filter { $0.team != nil }
                        .filter { $0.pass != nil }
                        .filter { $0.player != nil }
                        .forEach { event in
                            if event.team!.id.rawValue == match.homeTeam.id.rawValue { // TODO: TeamIDで統一したい
                                if homePlayerAndPassList[event.player!] == nil {
                                    homePlayerAndPassList[event.player!] = []
                                }
                                homePlayerAndPassList[event.player!]?.append(event)
                            } else {
                                if awayPlayerAndPassList[event.player!] == nil {
                                    awayPlayerAndPassList[event.player!] = []
                                }
                                awayPlayerAndPassList[event.player!]?.append(event)
                            }
                        }
//                    setupPlayerSelectView()
                    configurePlayerSelectionButton(playerSelectButton)
                } catch {
                    fatalError()
                }
            }
        }
    }

    private func configurePlayerSelectionButton(_ target: UIButton) {

        var actions = [UIMenuElement]()
        let players = isHome ? homePlayerAndPassList : awayPlayerAndPassList
        players.forEach { player, passes in
            actions.append(
                UIAction(title: player.name, state: .off, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let events = self.isHome ? self.homePlayerAndPassList[player]! : self.awayPlayerAndPassList[player]!
                    self.passDrawingView.events = events
                    self.passDrawingView.setNeedsDisplay()

                    self.teamAndPlayerLabel.text = self.isHome ? "Home Team : \(player.name)" : "Away Team : \(player.name)"
                })
            )
        }

        target.menu = UIMenu(title: "", options: .displayInline, children: actions)
        target.showsMenuAsPrimaryAction = true
        target.setTitle("", for: .normal)
    }

//
//    func setupPlayerSelectView() {
//        let players = homePlayerAndPassList.keys
//
//        let stackView = UIStackView(frame: .zero)
//        stackView.axis = .vertical
//        stackView.alignment = .center
//        stackView.distribution = .fillEqually
//
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: view.topAnchor),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            stackView.widthAnchor.constraint(equalToConstant: 120)
//        ])
//
//        players.forEach { player in
//            let button = PlayerButton(frame: .init(x: 0, y: 0, width: 120, height: 36))
//            button.player = player
//            button.setTitle(player.name, for: .normal)
//            button.setTitleColor(.darkGray, for: .normal)
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//            button.addTarget(self, action: #selector(playerSelected), for: .touchUpInside)
//            stackView.addArrangedSubview(button)
//        }
//    }
//
//    @objc func playerSelected(_ sender: PlayerButton) {
//        let events = homePlayerAndPassList[sender.player!]!
//        passDrawingView.events = events
//        passDrawingView.setNeedsDisplay()
//    }

    func drawField() {
        let viewFrame = view.frame
        let viewRatio = viewFrame.size.height / viewFrame.size.width

        if Field.fieldRatio > viewRatio {
            let verticalMarginRatio: CGFloat = 0.1
            let height = viewFrame.size.height * (1 - verticalMarginRatio * 2)
            let width = height / Field.fieldRatio
            fieldView = .init(
                frame: .init(
                    x: (view.frame.size.width - width) / 2,
                    y: (view.frame.size.height - height) / 2,
                    width: width,
                    height: height
                )
            )
        } else {
            let horizontalMarginRatio: CGFloat = 0.1
            let width = viewFrame.size.width * (1 - horizontalMarginRatio * 2)
            let height = width * Field.fieldRatio
            fieldView = .init(
                frame: .init(
                    x: (view.frame.size.width - width) / 2,
                    y: (view.frame.size.height - height) / 2,
                    width: width,
                    height: height
                )
            )
        }

        fieldView?.backgroundColor = .darkGray
        view.addSubview(fieldView!)
    }
}

fileprivate class PlayerButton: UIButton {
    var player: Player?
}


fileprivate class PassDrawingView: UIView {

    var events: [Event] = []

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        backgroundColor = .clear

        events
            .filter { $0.pass!.type == nil } // コーナーキックとかは除外する
            .forEach { event in
                guard
                    let from = event.location,
                    let to = event.pass?.endLocation
                else { return }

                // パスの線を描く
                // MEMO: 間際らしいが、statsbombのxは縦（長い方）、yが横（短い方）を表しているぽい
                let line = makeArrowBezierPath(
                    from: .init(
                        x: frame.size.width * (from[1] / 80),
                        y: frame.size.height * (1 - from[0] / 120)
                    ),
                    to: .init(
                        x: frame.size.width * (to[1] / 80),
                        y: frame.size.height * (1 - to[0] / 120)
                    )
                )

                let arrowColor: UIColor
                if let _ = event.pass!.outcome {
                    arrowColor = .red.withAlphaComponent(0.8)
                } else {
                    arrowColor = .green.withAlphaComponent(0.8)
                }
                arrowColor.setStroke()
                line.lineWidth = 2
                line.stroke()
            }
    }
}

fileprivate func makeArrowBezierPath(from: CGPoint, to: CGPoint) -> UIBezierPath {
    let line = UIBezierPath()
    line.move(to: from)
    line.addLine(to:to)

    let r: CGFloat = 10

    // 長さ
    var radian = atan((to.y - from.y) / (to.x - from.x))
    if to.y > from.y {
        if to.x < from.x {
            // そのままでOK
        } else {
            radian = radian - CGFloat.pi
        }
    } else {
        if to.x < from.x {
            // そのままでOK
        } else {
            radian = radian - CGFloat.pi
        }
    }

    let radian_a = radian + CGFloat.pi / 4
    let radian_b = radian - CGFloat.pi / 4

    let modified_a = radian_a > CGFloat.pi ? radian_a + CGFloat.pi : radian_a
    let modified_b = radian_b > CGFloat.pi ? radian_b + CGFloat.pi : radian_b

    let point_a: CGPoint = .init(
        x: to.x + r * cos(modified_a),
        y: to.y + r * sin(modified_a)
    )
    let point_b: CGPoint = .init(
        x: to.x + r * cos(modified_b),
        y: to.y + r * sin(modified_b)
    )
    line.move(to: to)
    line.addLine(to:point_a)

    line.move(to: to)
    line.addLine(to:point_b)

    line.close()
    return line
}

