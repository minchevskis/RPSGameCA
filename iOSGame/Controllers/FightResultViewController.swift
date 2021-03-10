//
//  FightResultViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 3.3.21.
//

import UIKit

class FightResultViewController: UIViewController {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    
    @IBOutlet weak var lblWinner: UILabel!
    @IBOutlet weak var lblLoser: UILabel!
    
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let winner = game?.winer {
            lblWinner.text = winner.username
            
            let loser = game?.players.filter({ $0.id != winner.id }).first
            lblLoser.text = loser?.username
        }
    }
    

    @IBAction func onHome(_ sender: UIButton) {
        if let gameController = presentingViewController as? GameViewController {
            dismiss(animated: false) {
                gameController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func onReplay(_ sender: UIButton) {
        
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
    }
}
