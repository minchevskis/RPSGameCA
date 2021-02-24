//
//  GameViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var lblGameStatus: UILabel!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        
        lblGameStatus.text = game?.state.rawValue
    }
    
    private func setGameStatusListener() {
        guard let game = game else { return }
        
        DataStore.shared.setGameStateListener(game: game) { [weak self] (updatedGame, error) in
            if let updatedGame = updatedGame {
                self?.updateGame(updatedGame: updatedGame)
            }
        }
    }
    
    private func updateGame(updatedGame: Game) {
        lblGameStatus.text = updatedGame.state.rawValue
        
        game = updatedGame
    }
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func onClose(_ sender: UIButton) {
        let alert = UIAlertController(title: nil,
                                      message: "Are you sure you want to exit?",
                                      preferredStyle: .alert)
        let exit = UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            //we need to update the other player
            self?.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(exit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
