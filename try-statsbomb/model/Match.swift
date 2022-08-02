//
//  Match.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/02.
//

import Foundation

struct Match: Decodable {
    typealias ID = Identifier<Self, Int>

    enum CodingKeys: String, CodingKey {
        case id = "match_id"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }

    let id: ID
    let homeTeam: MatchHomeTeam
    let awayTeam: MatchAwayTeam
}

struct MatchHomeTeam: Decodable {
    typealias ID = Identifier<Self, Int>

    enum CodingKeys: String, CodingKey {
        case id = "home_team_id"
        case name = "home_team_name"
    }

    let id: ID
    let name: String
}

struct MatchAwayTeam: Decodable {
    typealias ID = Identifier<Self, Int>

    enum CodingKeys: String, CodingKey {
        case id = "away_team_id"
        case name = "away_team_name"
    }

    let id: ID
    let name: String
}



/*
 "match_id" : 266989,
 "match_date" : "2016-11-06",
 "kick_off" : "20:45:00.000",
 "competition" : {
 "competition_id" : 11,
 "country_name" : "Spain",
 "competition_name" : "La Liga"
 },
 "season" : {
 "season_id" : 2,
 "season_name" : "2016/2017"
 },
 "home_team" : {
 "home_team_id" : 213,
 "home_team_name" : "Sevilla",
 "home_team_gender" : "male",
 "home_team_group" : null,
 "country" : {
 "id" : 214,
 "name" : "Spain"
 },
 "managers" : [ {
 "id" : 637,
 "name" : "Jorge Luis Sampaoli Moya",
 "nickname" : "Jorge Sampaoli",
 "dob" : "1960-03-13",
 "country" : {
 "id" : 11,
 "name" : "Argentina"
 }
 } ]
 },
 "away_team" : {
 "away_team_id" : 217,
 "away_team_name" : "Barcelona",
 "away_team_gender" : "male",
 "away_team_group" : null,
 "country" : {
 "id" : 214,
 "name" : "Spain"
 },
 "managers" : [ {
 "id" : 793,
 "name" : "Luis Enrique Martínez García",
 "nickname" : "Luis Enrique",
 "dob" : "1970-05-08",
 "country" : {
 "id" : 214,
 "name" : "Spain"
 }
 } ]
 },
 "home_score" : 1,
 "away_score" : 2,
 "match_status" : "available",
 "match_status_360" : "scheduled",
 "last_updated" : "2020-07-29T05:00",
 "last_updated_360" : "2021-06-13T16:17:31.694",
 "metadata" : {
 "data_version" : "1.1.0",
 "shot_fidelity_version" : "2",
 "xy_fidelity_version" : "2"
 },
 "match_week" : 11,
 "competition_stage" : {
 "id" : 1,
 "name" : "Regular Season"
 },
 "stadium" : {
 "id" : 349,
 "name" : "Estadio Ramón Sánchez Pizjuán",
 "country" : {
 "id" : 214,
 "name" : "Spain"
 }
 }
 }
 */
