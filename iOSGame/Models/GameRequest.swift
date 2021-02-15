//
//  GameRequest.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 3.2.21.
//

import Foundation

struct GameRequest: Codable {
    var id: String
    var from: String // UserID of the user who initiated the request
    var to: String // UserID of the user who was invited to play
    var createdAt: TimeInterval
    var fromUsername: String?
}
