//
//  Event.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/16.
//

import Foundation

// MARK: - event

struct Event: Codable {
    let id: String
    let timestamp: String
    let period: Int
    let player: Player?
    let pass: Pass?
}

struct Player: Codable, Hashable, CustomDebugStringConvertible {
    let id: Int
    let name: String

    var debugDescription: String {
        name
    }
}

// MARK: - pass

struct Pass: Codable {
    let recipient: Player?
    let length: Double
    let angle: Double
    let height: PassHeight
    let endLocation: [Double]
    let type: PassType?
    let bodyPart: PassBodyType?
}

struct PassHeight: Codable {
    let id: Int
    let name: String
}

struct PassType: Codable {
    let id: Int
    let name: String
}

struct PassBodyType: Codable {
    let id: Int
    let name: String
}
