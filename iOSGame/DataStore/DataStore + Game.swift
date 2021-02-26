//
//  DataStore + Game.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import Foundation

extension DataStore {
    func createGame (players: [User], completion: @escaping (_ game: Game?,_ error: Error?) -> Void) {
        let gamesRef = database.collection(FirebaseCollections.games.rawValue).document()
        let game = Game(id: gamesRef.documentID, players: players)
        
        do {
            try gamesRef.setData(from: game) { (error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(game, nil)
            }
        } catch {
            completion(nil, error)
            print(error.localizedDescription)
        }
    }
    
    func setGameListener(completion: @escaping (_ game: Game?,_ error: Error?) -> Void) {
        guard let localUserId = DataStore.shared.localUser?.id else { return }
        let gamesRef = database.collection(FirebaseCollections.games.rawValue)
            .whereField("playerIds", arrayContains: localUserId)
            .whereField("state", isEqualTo: Game.GameState.starting.rawValue)
            
        gameListener = gamesRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                let document = snapshot.documents[0]
                
                do {
                    let game = try document.data(as: Game.self)
                    completion(game, nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func removeGameListener() {
        gameListener?.remove()
        gameListener = nil
    }
    
    func setGameStateListener(game: Game, completion: @escaping (_ game: Game?,_ error: Error?) -> Void) {
        gameStatusListener = database.collection(FirebaseCollections.games.rawValue)
            .document(game.id)
            .addSnapshotListener { (document, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                if let document = document {
                    do {
                        let game = try document.data(as: Game.self)
                        completion(game, nil)
                    } catch {
                        print(error.localizedDescription)
                        completion(nil, error)
                    }
                }
            }
    }
    
    func removeGameStatusListener() {
        gameStatusListener?.remove()
        gameStatusListener = nil
    }
    
    func updateGameStatus(game: Game, newState: String) {
        let gameRef = database.collection(FirebaseCollections.games.rawValue).document(game.id)
        gameRef.updateData(["state":Game.GameState.inprogress.rawValue])
    }
    
    func checkForOngoingGameWith(userId: String, completion: @escaping (_ userInGame: Bool,_ error: Error?) -> Void) {
        let gameRef = database.collection(FirebaseCollections.games.rawValue)
            .whereField("playerIds", arrayContains: userId)
            .whereField("state", isNotEqualTo: Game.GameState.finished.rawValue)
        
        gameRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(true, error)
                return
            }
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion(true, nil)
            }
            completion(false, nil)
        }
    }
}
