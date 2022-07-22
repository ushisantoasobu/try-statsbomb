//
//  Lineup.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/22.
//

import Foundation

struct LineupTeam: Codable {
    let teamId: Int
    let teamName: String
    let lineup: [Lineup]
}

struct Lineup: Codable {
    let playerId: Int
    let playerName: String
    let positions: [LineupPosition]

    var isStartingMember: Bool {
        positions.contains { position in
            position.from == "00:00"
        }
    }

    var startingPosition: LineupPosition? {
        positions.filter { $0.from == "00:00" }.first
    }
}

struct LineupPosition: Codable {
    let from: String?
    let to: String?
    let positionId: Int
    let position: String
}
