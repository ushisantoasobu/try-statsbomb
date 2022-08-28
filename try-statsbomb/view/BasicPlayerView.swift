//
//  BasicPlayerView.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/23.
//

import Foundation
import UIKit

class BasicPlayerView: UIView {

    enum DisplayNameType {
        case name
        case number
    }

    enum DisplayPosition {
        case bottom
        case top
    }

    var player: Lineup?
    var displayNameType: DisplayNameType = .name
    var displayPosition: DisplayPosition = .bottom
    var isHome: Bool = true

    var nameLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .red

        nameLabel = UILabel(frame: .zero)
        addSubview(nameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let player = player else {
            return
        }

//        backgroundColor = .yellow // isHome ? .blue : .red
        self.backgroundColor = isHome ? .blue : .red
        self.backgroundColor?.setFill()
        UIGraphicsGetCurrentContext()!.fill(rect);

        switch displayNameType {
        case .name:
            nameLabel.text = player.playerNickname ?? player.playerName
        case .number:
            nameLabel.text = "\(player.jerseyNumber)"
        }

        nameLabel.textColor = isHome ? .blue : .red
        nameLabel.sizeToFit()
//        nameLabel.center = center

        let y: CGFloat
        switch displayPosition {
        case .bottom:
            y = frame.size.height * 0.5 + 10
        case .top:
            y = frame.size.height * 0.5 - 30
        }

        nameLabel.frame = .init(
            x: frame.size.width * 0.5 - nameLabel.frame.size.width / 2,
            y: y,
            width: nameLabel.frame.size.width,
            height: nameLabel.frame.size.height
        )
    }
}
