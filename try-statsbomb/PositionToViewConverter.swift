//
//  PositionToViewConverter.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/22.
//

import Foundation
import UIKit

struct PositionToViewConverter {

    let hSome: CGFloat = 0.12

    var h1: CGFloat { hSome }
    var h2: CGFloat { (h1 + h3) / 2 }
    var h3: CGFloat { 0.5 }
    var h4: CGFloat { (h3 + h5) / 2 }
    var h5: CGFloat { 1 - hSome }

    var v1: CGFloat { 0.1 }
    var v2: CGFloat { 0.22 }
    var v3: CGFloat { 0.36 }
    var v4: CGFloat { 0.5 }
    var v5: CGFloat { 0.64 }
    var v6: CGFloat { (v5 + v7) / 2 }
    var v7: CGFloat { 0.86 }

    func convert(positionId: Int) -> CGPoint {
        switch positionId {
        case 1:
            // Goalkeeper
            return .init(x: h3, y: v1)
        case 2:
            // Right Back
            return .init(x: h5, y: v2)
        case 3:
            // Right Center Back
            return .init(x: h4, y: v2)
        case 4:
            // Center Back
            return .init(x: h3, y: v2)
        case 5:
            // Left Center Back"
            return .init(x: h2, y: v2)
        case 6:
            // Left Back
            return .init(x: h1, y: v2)
        case 7:
            // Right Wing Back
            return .init(x: h5, y: v3)
        case 8:
            // Left Wing Back
            return .init(x: h1, y: v3)
        case 9:
            // Right Defensive Midfield
            return .init(x: h4, y: v3)
        case 10:
            // Center Defensive Midfield
            return .init(x: h3, y: v3)
        case 11:
            // Left Defensive Midfield
            return .init(x: h2, y: v3)
        case 12:
            // Right Midfield
            return .init(x: h5, y: v4)
        case 13:
            // Right Center Midfield
            return .init(x: h4, y: v4)
        case 14:
            //
            return .init(x: h3, y: v4)
        case 15:
            // Left Center Midfield"
            return .init(x: h2, y: v4)
        case 16:
            // Left Midfield
            return .init(x: h1, y: v4)
        case 17:
            // Right Wing
            return .init(x: h5, y: v5)
        case 18:
            return .init(x: h4, y: v5)
        case 19:
            return .init(x: h3, y: v5)
        case 20:
            return .init(x: h2, y: v5)
        case 21:
            // Left Wing
            return .init(x: h1, y: v5)
        case 22:
            // Right Center Forward"
            return .init(x: h4, y: v7)
        case 23:
            // Center Forward
            return .init(x: h3, y: v7)
        case 24:
            // Left Center Forward
            return .init(x: h2, y: v7)
        case 25:
            // Secondary Striker
            return .init(x: h3, y: v6)
        default:
            fatalError()
        }
    }
}
