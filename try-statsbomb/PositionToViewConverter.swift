//
//  PositionToViewConverter.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/22.
//

import Foundation
import UIKit

struct PositionToViewConverter {

    func convert(positionId: Int) -> CGPoint {
        switch positionId {
        case 1:
            // Goalkeeper
            return .init(x: 0.5, y: 0.9)
        case 2:
            // Right Back
            return .init(x: 0.9, y: 0.6)
        case 3:
            // Right Center Back
            return .init(x: 0.7, y: 0.7)
        case 4:
            // Center Back
            return .init(x: 0.5, y: 0.75)
        case 5:
            // Left Center Back"
            return .init(x: 0.3, y: 0.7)
        case 6:
            // Left Back
            return .init(x: 0.1, y: 0.6)
        case 7:
            // Right Wing Back
            return .init(x: 0.9, y: 0.5)
        case 8:
            // Left Wing Back
            return .init(x: 0.1, y: 0.5)
        case 9:
            // Right Defensive Midfield
            return .init(x: 0.7, y: 0.5)
        case 10:
            // Center Defensive Midfield
            return .init(x: 0.5, y: 0.5)
        case 11:
            // Left Defensive Midfield
            return .init(x: 0.3, y: 0.5)
        case 12:
            // Right Midfield
            return .init(x: 0.8, y: 0.3)
        case 13:
            // Right Center Midfield
            return .init(x: 0.7, y: 0.3)
        case 14:
            fatalError()
        case 15:
            // Left Center Midfield"
            return .init(x: 0.3, y: 0.3)
        case 16:
            // Left Midfield
            return .init(x: 0.2, y: 0.3)
        case 17:
            // Right Wing
            return .init(x: 0.9, y: 0.15)
        case 18:
            return .init(x: 0, y: 0)
        case 19:
            return .init(x: 0, y: 0)
        case 20:
            return .init(x: 0, y: 0)
        case 21:
            // Left Wing
            return .init(x: 0.1, y: 0.15)
        case 22:
            // Right Center Forward"
            return .init(x: 0.7, y: 0.1)
        case 23:
            // Center Forward
            return .init(x: 0.5, y: 0.1)
        case 24:
            // Left Center Forward
            return .init(x: 0.3, y: 0.1)
        case 25:
            // Secondary Striker
            return .init(x: 0.5, y: 0.25)
        default:
            fatalError()
        }
    }
}
