//
//  WelcomeViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var txtUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUsername.layer.cornerRadius = 10
        txtUsername.layer.masksToBounds = true
        txtUsername.returnKeyType = .continue
        txtUsername.delegate = self
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUsername.becomeFirstResponder()
    }
    
    @IBAction func onContinue(_ sender: UIButton) {
        guard let username = txtUsername.text?.lowercased() else { return }
        
        DataStore.shared.checkForExistingUsername(username) { [weak self] (exists, _) in
            if exists {
                //show error
                self?.showErrorAlert(username: username)
                return
            }
        }
        
        DataStore.shared.continueWithGuest(username: username) { [weak self] (user, error) in
            if let user = user {
                DataStore.shared.localUser = user
                self?.performSegue(withIdentifier: "HomeSegue", sender: nil)
            }
        }
    }
    
    func showErrorAlert(username: String) {
        let alert = UIAlertController(title: "Error",
                                      message: "\(username) already exists. Please pick another one",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
