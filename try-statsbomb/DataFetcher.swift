//
//  DataFetcher.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/07/22.
//

import Foundation

struct DataFetcher {

    enum FetchError: Error {
        case fileNotFound
        case failedToData
    }

    func fetch(id: Int) async throws -> Game {
        async let lineups = fetchLineups(id: id)
        async let events = fetchEvents(id: id)
        return try await Game(lineups: lineups, events: events)
    }

    func fetchCompetitions() async throws -> [Competition] {
        guard let jsonFilePath = Bundle.main.url(forResource: "data/competitions", withExtension: "json") else {
            throw FetchError.fileNotFound
        }

        guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
            throw FetchError.failedToData
        }

        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Competition].self, from: jsonData)
    }

    func fetchMatches(
        competitionId: Competition.ID,
        seasonId: Season.ID
    ) async throws -> [Match] {
        let path = "data/matches/\(competitionId.rawValue)/\(seasonId.rawValue)"
        guard let jsonFilePath = Bundle.main.url(forResource: path, withExtension: "json") else {
            throw FetchError.fileNotFound
        }

        guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
            throw FetchError.failedToData
        }

        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Match].self, from: jsonData)
    }

    private func fetchLineups(id: Int) async throws -> [LineupTeam] {
        guard let jsonFilePath = Bundle.main.url(forResource: "data/lineups/\(id)", withExtension: "json") else {
            throw FetchError.fileNotFound
        }

        guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
            throw FetchError.failedToData
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([LineupTeam].self, from: jsonData)
    }

    private func fetchEvents(id: Int) async throws -> [Event] {
        guard let jsonFilePath = Bundle.main.url(forResource: "data/events/\(id)", withExtension: "json") else {
            throw FetchError.fileNotFound
        }

        guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
            throw FetchError.failedToData
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Event].self, from: jsonData)
    }
}
