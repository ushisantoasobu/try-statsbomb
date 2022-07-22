//
//  BasicPlayerView.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/23.
//

import Foundation
import UIKit

class BasicPlayerView: UIView {

    var player: Lineup?
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

        nameLabel.text = player.playerName
        nameLabel.sizeToFit()
//        nameLabel.center = center
        nameLabel.frame = .init(
            x: frame.size.width * 0.5 - nameLabel.frame.size.width / 2,
            y: frame.size.height * 0.5 + 10,
            width: nameLabel.frame.size.width,
            height: nameLabel.frame.size.height
        )
    }
}
