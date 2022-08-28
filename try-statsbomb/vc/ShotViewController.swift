//
//  ShotViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/25.
//

import UIKit

class ShotViewController: UIViewController {

    var competition: Competition!
    var match: Match!

    static func instantiate(
        competition: Competition,
        match: Match
    ) -> ShotViewController {
        let vc = ShotViewController()
        vc.competition = competition
        vc.match = match
        return vc
    }

    let stageView = UIView(frame: .zero)
    let fieldView = FieldView(frame: .zero)
    let prevButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    let shotDetailLabel = UILabel(frame: .zero)

    var homeLineupList: [Lineup] = []
    var awayLineupList: [Lineup] = []

    var shotEventList: [Event] = []
    var currentShotIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        navigationItem.title = "シュート"
        setupCloseButtonOnNav()

        stageView.backgroundColor = .clear
        stageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stageView)
        NSLayoutConstraint.activate([
            stageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            stageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 48),
            stageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -48),
            stageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
        ])

        fieldView.backgroundColor = .clear
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        stageView.addSubview(fieldView)
        NSLayoutConstraint.activate([
            fieldView.topAnchor.constraint(equalTo: stageView.topAnchor),
            fieldView.leadingAnchor.constraint(equalTo: stageView.leadingAnchor),
            fieldView.trailingAnchor.constraint(equalTo: stageView.trailingAnchor),
            fieldView.bottomAnchor.constraint(equalTo: stageView.bottomAnchor)
        ])

        prevButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prevButton)
        NSLayoutConstraint.activate([
            prevButton.topAnchor.constraint(equalTo: stageView.bottomAnchor, constant: 16),
            prevButton.trailingAnchor.constraint(equalTo: stageView.centerXAnchor, constant: -100)
        ])
        prevButton.setTitle("prev", for: .normal)
        prevButton.tintColor = .blue
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: stageView.bottomAnchor, constant: 16),
            nextButton.leadingAnchor.constraint(equalTo: stageView.centerXAnchor, constant: 100)
        ])
        nextButton.setTitle("next", for: .normal)
        nextButton.tintColor = .blue
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        shotDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shotDetailLabel)
        NSLayoutConstraint.activate([
            shotDetailLabel.bottomAnchor.constraint(equalTo: stageView.bottomAnchor, constant: -120),
            shotDetailLabel.centerXAnchor.constraint(equalTo: stageView.centerXAnchor)
        ])
        shotDetailLabel.font = .systemFont(ofSize: 21)
        shotDetailLabel.numberOfLines = 0
    }

    @objc private func prevTapped() {
        if currentShotIndex == 0 {
            return
        }

        currentShotIndex -= 1
        display()
    }

    @objc private func nextTapped() {
        if currentShotIndex == shotEventList.count - 1 {
            return
        }

        currentShotIndex += 1
        display()
    }

    private func fetch() {
        let fetcher = DataFetcher()

        Task {
            do {
                let game = try await fetcher.fetch(id: match.id)
                homeLineupList = game.lineups[0].lineup
                awayLineupList = game.lineups[1].lineup
                shotEventList = game.events.filter { $0.shot != nil }

                display()
            } catch {
                print(error)
                fatalError()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetch()
    }

    private func display() {
        fieldView.subviews.forEach { view in
            if view is BasicPlayerView {
                view.removeFromSuperview()
            }
            if view is ShotView {
                view.removeFromSuperview()
            }
        }

        // players
        do {
            let event = shotEventList[currentShotIndex]

            // shooter
            let player = event.player
            let location = event.location!

            let playerView = BasicPlayerView(
                frame: .init(x: 0, y: 0, width: 4, height: 4)
            )
//            playerView.center = fieldView.convertToPoint(x: 80, y: 120)
            playerView.center = fieldView.convertToPoint(x: location[1], y: location[0])
            playerView.displayNameType = .number
            playerView.displayPosition = .bottom
            let lineup = detectLineup(player: player!)
            playerView.player = lineup.0
//            event.team!.id == lineup.0.
            playerView.isHome = lineup.1
            fieldView.addSubview(playerView)

            // other players
            event.shot?.freezeFrame?.forEach({ frame in
                let player = frame.player
                let location = frame.location

                let playerView = BasicPlayerView(
                    frame: .init(x: 0, y: 0, width: 4, height: 4)
                )
                playerView.center = fieldView.convertToPoint(x: location[1], y: location[0])
                playerView.displayNameType = .number
                playerView.displayPosition = frame.teammate ? .bottom : .top
                let lineup = detectLineup(player: player)
                playerView.player = lineup.0
                playerView.isHome = lineup.1
                fieldView.addSubview(playerView)
            })

            // shot
            let view = ShotView(frame: .zero)
            fieldView.addSubview(view)
            view.frame = fieldView.fieldFrame
            view.backgroundColor = .clear
            view.shotEvent = event

            // shotDetailLabel
            let text = """
\(event.period == 1 ? "前半" : "後半") \(event.timestamp)
シュートした人: \(lineup.0.playerNickname ?? lineup.0.playerName) （\(event.team!.name)）
結果: \(event.shot!.outcome.name)
ゴール期待値: \(event.shot!.statsbombXg)
"""
            shotDetailLabel.text = text
        }
    }

    func detectLineup(player: Player) -> (Lineup, Bool) {
        if let lineup = homeLineupList.first(where: { lineup in
            lineup.playerId == player.id
        }) {
            return (lineup, true)
        }

        if let lineup = awayLineupList.first(where: { lineup in
            lineup.playerId == player.id
        }) {
            return (lineup, false)
        }

        fatalError()
    }
}

class ShotView: UIView {

    var shotEvent: Event?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let shotEvent = shotEvent else {
            return
        }

        let start = shotEvent.location!
        let end = shotEvent.shot!.endLocation

        let line = UIBezierPath()
        line.move(
            to: .init(
                x: start[1] / 80 * rect.width,
                y: (120 - start[0]) / 120 * rect.height
            )
        )
        line.addLine(
            to: .init(
                x: end[1] / 80 * rect.width,
                y: (120 - end[0]) / 120 * rect.height
            )
        )
        line.close()
        UIColor.gray.setStroke()
        line.lineWidth = CGFloat(1)
        line.stroke()
    }
}

class FieldView: UIView {

    let fieldAspectRatio = (Field.fieldHeight + Field.goalHeight) / Field.fieldWidth

    func convertToPoint(x: Double, y: Double) -> CGPoint {
        let drawingRect: CGRect
        if fieldAspectRatio > frame.size.height / frame.size.width {
            drawingRect = .init(
                x: (frame.size.width - frame.size.height / fieldAspectRatio) / 2,
                y: 0,
                width: frame.size.height / fieldAspectRatio,
                height: frame.size.height
            )
        } else {
            drawingRect = .init(
                x: frame.size.width,
                y: frame.size.height - (frame.size.height - frame.size.width * fieldAspectRatio) / 2,
                width: frame.size.width,
                height: frame.size.width * fieldAspectRatio
            )
        }

        return .init(
            x: drawingRect.minX + x / 80 * drawingRect.width,
            y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight) + (120 - y) / 120 * drawingRect.height
        )
    }

    var fieldFrame: CGRect {
        let drawingRect: CGRect
        if fieldAspectRatio > frame.size.height / frame.size.width {
            drawingRect = .init(
                x: (frame.size.width - frame.size.height / fieldAspectRatio) / 2,
                y: 0,
                width: frame.size.height / fieldAspectRatio,
                height: frame.size.height
            )
        } else {
            drawingRect = .init(
                x: frame.size.width,
                y: frame.size.height - (frame.size.height - frame.size.width * fieldAspectRatio) / 2,
                width: frame.size.width,
                height: frame.size.width * fieldAspectRatio
            )
        }

        let goalHeight = drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
        return .init(
            x: drawingRect.minX,
            y: drawingRect.minY + goalHeight,
            width: drawingRect.width,
            height: drawingRect.maxY - goalHeight * 2
        )
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let drawingRect: CGRect
        if fieldAspectRatio > frame.size.height / frame.size.width {
            drawingRect = .init(
                x: (frame.size.width - frame.size.height / fieldAspectRatio) / 2,
                y: 0,
                width: frame.size.height / fieldAspectRatio,
                height: frame.size.height
            )
        } else {
            drawingRect = .init(
                x: frame.size.width,
                y: frame.size.height - (frame.size.height - frame.size.width * fieldAspectRatio) / 2,
                width: frame.size.width,
                height: frame.size.width * fieldAspectRatio
            )
        }

        print(drawingRect)

        // 枠
        do {
            let line = UIBezierPath()
            line.move(
                to: .init(
                    x: drawingRect.minX,
                    y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: drawingRect.minX,
                    y: drawingRect.maxY - drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: drawingRect.maxX,
                    y: drawingRect.maxY - drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: drawingRect.maxX,
                    y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: drawingRect.minX,
                    y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat(1)
            line.stroke()
        }

        // 中央線
        do {
            let line = UIBezierPath()
            line.move(
                to: .init(
                    x: drawingRect.minX,
                    y: drawingRect.height / 2
                )
            )
            line.addLine(
                to: .init(
                    x: drawingRect.maxX,
                    y: drawingRect.height / 2
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat(1)
            line.stroke()
        }

        // ゴール（上）
        let centerX = drawingRect.width / 2 + drawingRect.minX
        do {
            let line = UIBezierPath()
            line.move(
                to: .init(
                    x: centerX - drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: centerX - drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.minY
                )
            )
            line.addLine(
                to: .init(
                    x: centerX + drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.minY
                )
            )
            line.addLine(
                to: .init(
                    x: centerX + drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.minY + drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat(1)
            line.stroke()
        }

        // ゴール（下）
        do {
            let line = UIBezierPath()
            line.move(
                to: .init(
                    x: centerX - drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.maxY - drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.addLine(
                to: .init(
                    x: centerX - drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.maxY
                )
            )
            line.addLine(
                to: .init(
                    x: centerX + drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.maxY
                )
            )
            line.addLine(
                to: .init(
                    x: centerX + drawingRect.width * Field.goalWidth / (Field.fieldWidth + Field.goalWidth) / 2,
                    y: drawingRect.maxY - drawingRect.height * Field.goalHeight / (Field.fieldHeight + Field.goalHeight)
                )
            )
            line.close()
            UIColor.gray.setStroke()
            line.lineWidth = CGFloat(1)
            line.stroke()
        }
    }
}
