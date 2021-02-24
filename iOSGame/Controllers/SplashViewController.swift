//
//  SplashViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 24.2.21.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       checkForUser()
    }
    
    func checkForUser() {
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWithId(id: id) { (user, error) in
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                    return
                }
                do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
        }
    }

   
}
