//
//  Environment.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/05.
//

import Foundation
import UIKit

struct Field {
    static let fieldWidth: CGFloat = 80
    static let fieldHeight: CGFloat = 120
    static let goalWidth: CGFloat = 8
    static let goalHeight: CGFloat = 2.67
    static let fieldDimension: CGSize = .init(width: fieldWidth, height: fieldHeight)
    static let fieldRatio: CGFloat = fieldHeight / fieldWidth
}
