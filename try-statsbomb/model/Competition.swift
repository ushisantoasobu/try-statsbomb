//
//  Competition.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/01.
//

import Foundation

struct Competition: Decodable {
    typealias ID = Identifier<Self, Int>

    enum CodingKeys: String, CodingKey {
        case id = "competition_id"
        case name = "competition_name"
        case gender = "competition_gender"
        case isYouth = "competition_youth"
        case seasonId = "season_id"
        case season = "season_name"
    }

    let id: ID
    let name: String
    let gender: String
    let isYouth: Bool
    let seasonId: Season.ID
    let season: String
}

struct Season: Decodable {
    typealias ID = Identifier<Self, Int>

    enum CodingKeys: String, CodingKey {
        case id = "season_id"
    }

    let id: ID
}
