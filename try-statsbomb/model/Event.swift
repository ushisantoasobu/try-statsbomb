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
    let shot: Shot?
    let pass: Pass?
    let team: Team?
    let location: [Double]?
    let possessionTeam: Team

    func convertTimestampToSeconds() -> Double {
        let splitByColon = timestamp.split(separator: ":")
        let hour = Double(splitByColon[0])
        let min = Double(splitByColon[1])
        let secAndmillSec = splitByColon[2].split(separator: ".")
        let sec = Double(secAndmillSec[0])
        let millSec = Double(secAndmillSec[1])
        return hour! * 60 * 60 + min! * 60 + sec! + millSec! / 1000
    }
}

struct Player: Decodable, Hashable, CustomDebugStringConvertible {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String

    var debugDescription: String {
        name
    }
}

// MARK: - shot

struct Shot: Decodable {
    let outcome: ShotOutcome
}

struct ShotOutcome: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
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
    let outcome: PassOutcome?
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

struct PassOutcome: Decodable {
    typealias ID = Identifier<Self, Int>

    let id: ID
    let name: String
}
