//
//  PushNotificationManager.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 10.3.21.
//

import Foundation

class PushNotificationManager {
    static let shared = PushNotificationManager()
    init() {}
    
    private(set) var gameRequest: GameRequest?
    
    func handlePushNotification(dict: [String:Any]) {
        guard let requestId = dict["id"] as? String else {
            return
        }
        
        DataStore.shared.getGameRequestWith(id: requestId) { (request, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.gameRequest = request
        }
    }
    
    func getGameRequest() -> GameRequest? {
        return gameRequest
    }
    
    func clearVariables() {
        gameRequest = nil
    }
}
