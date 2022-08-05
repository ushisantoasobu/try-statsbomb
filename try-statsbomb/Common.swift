//
//  Common.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/20.
//

import Foundation
import UIKit

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

extension UIViewController {

    func setupCloseButtonOnNav() {
        navigationItem.leftBarButtonItem = .init(
            title: "閉じる",
            style: .plain,
            target: self,
            action: #selector(closeButtonOnNavTapped)
        )
    }

    @objc func closeButtonOnNavTapped() {
        dismiss(animated: true, completion: nil)
    }
}
