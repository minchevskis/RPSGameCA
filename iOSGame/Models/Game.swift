//
//  Game.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import Foundation
import UIKit

enum Moves: String, Comparable, Codable, CaseIterable {
    case idle
    case rock
    case scissors
    case paper
    
    static func < (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .paper):
            return true
        case (.paper, .scissors):
            return true
        case (.scissors, .rock):
            return true
        case (.idle, .paper):
            return true
        case (.idle, .rock):
            return true
        case (.idle, .scissors):
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .rock):
            return true
        case (.scissors, .scissors):
            return true
        case (.paper, .paper):
            return true
        case (.idle, .idle):
            return true
        default:
            return false
        }
    }
    
    //Topmost Y coordinate fo Both hand (hidden)
     static var maximumY: CGFloat {
        return -500
    }
    
    //Bottom most Y coordinate for Both hands (fully shown)
    static func minimumY(isOpponent: Bool) -> CGFloat{
        return isOpponent ? -90 : -30
    }
    
    func imageName(isOpponent: Bool) -> String {
        switch self {
        case .idle:
            return isOpponent ? "steady" : "steady_bottom"
        case .paper:
            return isOpponent ? "paper_top" : "paper_bot"
        case .rock:
            return isOpponent ? "rock_top" : "rock_bottom"
        case .scissors:
            return isOpponent ? "scisors_top" : "scrissors_bot"
        }
    }
    
}

struct Game: Codable {
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    
    var id: String
    var players: [User]
    
    var moves = [String:Moves]()
    
    var playerIds: [String]
    var winer: User?
    var createdAt: TimeInterval
    var state: GameState
    
    
    init(id: String, players: [User], moves: [String:Moves]) {
        self.id = id
        self.players = players
        self.moves = moves
        
        playerIds = players.compactMap( { $0.id } )
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
