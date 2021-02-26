//
//  DataStore+GameRequests.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 3.2.21.
//

import Foundation


extension DataStore {
    
    func startGameRequest(userID: String, completion: @escaping (_ request: GameRequest?,_ error: Error?) -> Void) {
        let requestRef = database.collection(FirebaseCollections.gameRequests.rawValue).document()
        let gameRequest = createGameRequest(toUser: userID, id: requestRef.documentID)
        
        do {
            try requestRef.setData(from: gameRequest, completion: { (error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(gameRequest, nil) 
            })
        } catch {
            completion(nil, error)
        }
    }
    
    private func createGameRequest(toUser: String, id: String) -> GameRequest? {
        guard let localUserID = localUser?.id else { return nil }
        return GameRequest(id: id,
                           from: localUserID,
                           to: toUser,
                           createdAt: Date().toMiliseconds(),
                           fromUsername: localUser?.username)
    }
    
    func checkForExistingGameRequest(toUser: String,
                              fromUser: String,
                              completion: @escaping(_ exists: Bool,_ error: Error?) -> Void) {
        let gameRequestsRef = database.collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("from", isEqualTo: fromUser)
            .whereField("to", isEqualTo: toUser)
        
        gameRequestsRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            if let snapshot = snapshot , snapshot.documents.count > 0 {
                completion(true, nil)
                return
            }
            
            completion(false, nil)
        }
    }
    
    func setGameRequestListener() {
        if gameRequestListener != nil {
            removeGameRequestListener()
        }
        
        guard let localUserID = localUser?.id else { return }

        gameRequestListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("to", isEqualTo: localUserID)
            .addSnapshotListener { (snapshot, error) in
            
                if let snapshot = snapshot, let document = snapshot.documents.first {
                    
                    do {
                        let gameRequest = try document.data(as: GameRequest.self)
                        NotificationCenter.default.post(name: Notification.Name("DidRecieveGameRequestNotification"), object: nil, userInfo: ["GameRequest":gameRequest as Any])
                        print("New GameRequest with" + (gameRequest?.from ?? ""))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func removeGameRequestListener() {
        gameRequestListener?.remove()
        gameRequestListener = nil
    }
    
    func setGameRequestDelitionListener() {
        if gameRequestDelitionListener != nil {
            removeGameRequestDeletionlistener()
        }
        
        guard let localUserID = localUser?.id else { return }

        gameRequestDelitionListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("to", isEqualTo: localUserID)
            .addSnapshotListener { (snapshot, error) in
            
                if let snapshot = snapshot {
                    
                    do {
                        print("Game Requests count: \(snapshot.documents.count)")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func removeGameRequestDeletionlistener() {
        gameRequestDelitionListener?.remove()
        gameRequestDelitionListener = nil
    }
    
    func deleteGameRequest(gameRequest: GameRequest) {
        let gameRequestRef = database
            .collection(FirebaseCollections
            .gameRequests.rawValue)
            .document(gameRequest.id)
        
        gameRequestRef.delete()
        
    }
    
}
