//
//  Event.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/16.
//

import Foundation

// MARK: - event

struct Event: Decodable {
    typealias ID = Identifier<Self, String>

    let id: ID
    let timestamp: String
    let period: Int
    let player: Player?
    let pass: Pass?
    let team: Team?
}

struct Player: Decodable, Hashable, CustomDebugStringConvertible {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String

    var debugDescription: String {
        name
    }
}

// MARK: - pass

struct Pass: Decodable {
    let recipient: Player?
    let length: Double
    let angle: Double
    let height: PassHeight
    let endLocation: [Double]
    let type: PassType?
    let bodyPart: PassBodyType?
}

struct PassHeight: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
}

struct PassType: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
}

struct PassBodyType: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
}

struct Team: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
}
