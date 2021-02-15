//
//  WelcomeViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func onContinue(_ sender: UIButton) {
        
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWithId(id: id) { (user, error) in
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "HomeSegue", sender: nil)
                }
            }
            return
        }
        
        DataStore.shared.continueWithGuest { (user, error) in
            if let user = user {
                DataStore.shared.localUser = user
                self.performSegue(withIdentifier: "HomeSegue", sender: nil)
            }
        }
        
        
    }
    
}
