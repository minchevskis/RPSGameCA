//
//  DataStore.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseMessaging

class DataStore {
    
    enum FirebaseCollections: String {
        case users
        case gameRequests
        case games
    }
    
    static let shared = DataStore()
    let database = Firestore.firestore()
    var localUser: User? {
        didSet {
//            if localUser?.avatarImage == nil {
//                localUser?.avatarImage = avatars.randomElement()
                localUser?.setRandomImage()
                if localUser?.deviceToken == nil {
                    setPushToken()
                }
                guard let localUser = localUser else { return }
                DataStore.shared.saveUser(user: localUser) { (_, _) in
    
                }
            }
        }
//    }
    var usersListener: ListenerRegistration?
    var gameRequestListener: ListenerRegistration?
    var gameRequestDelitionListener: ListenerRegistration?
    var gameListener: ListenerRegistration?
    var gameStatusListener: ListenerRegistration?
    
    init(){}
    
    func setPushToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.localUser?.deviceToken = token
                self.saveUser(user: self.localUser!) { (_, _) in
            }
          }
        }
    }
    
    func continueWithGuest(username: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        Auth.auth().signInAnonymously { (result, error) in 
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let currentUser = result?.user {
                let localUser = User.createUser(id: currentUser.uid, username: username)
                self.saveUser(user: localUser, completion: completion)
            }
        }
    }
    
    func saveUser(user: User,completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let userRef = database.collection(FirebaseCollections.users.rawValue).document(user.id!)
        
        do {
            try userRef.setData(from: user) { (error) in
                completion(user, error)
            }
        } catch {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func getAllUsers(completion: @escaping (_ users: [User]?, _ error: Error?) -> Void) {
        let usersRef = database.collection(FirebaseCollections.users.rawValue)
                usersRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    if let snapshot = snapshot {
                        do {
                            let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })
                            completion(users, nil)
                        } catch (let error) {
                            completion(nil, error)
                        }
                    }
                }
    }
    
    func checkForExistingUsername(_ username: String,_ completion: @escaping (_ exists: Bool,_ error: Error?) -> Void) {
        let usersRef = database
            .collection(FirebaseCollections.users.rawValue)
            .whereField("username", isEqualTo: username)
        
        usersRef.getDocuments { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count == 0 {
                //we dont have users with the same username
                completion(false, nil)
                return
            }
            completion(true, error)
        }
    }
    
    func getUserWithId(id: String, completion: @escaping (_ user: User?,_ error: Error?) -> Void) {
        let usersRef = database.collection(FirebaseCollections.users.rawValue).document(id)
        
         usersRef.getDocument { (document, error) in
            do {
                let user = try document?.data(as: User.self)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func setUsersListener(completion: @escaping () -> Void) {
        if usersListener != nil {
            usersListener?.remove()
            usersListener = nil
        }
        
        let usersRef = database.collection(FirebaseCollections.users.rawValue)
        
        usersListener =  usersRef.addSnapshotListener { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion()
            }
        }
    }
    
    func removeUsersListener() {
        usersListener?.remove()
        usersListener = nil
    }
    
    
}
