//
//  Game.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import Foundation

struct Game: Codable {
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    
    var id: String
    var players: [User]
    var playerIds: [String]
    var winer: User?
    var createdAt: TimeInterval
    var state: GameState
    
    init(id: String, players: [User]) {
        self.id = id
        self.players = players
        playerIds = players.compactMap( { $0.id } )
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
