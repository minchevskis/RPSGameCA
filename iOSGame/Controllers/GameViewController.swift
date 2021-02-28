//
//  GameViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    
    enum HandChoise: Equatable {
        case rock
        case scissors
        case paper
    }

    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var btnRock: UIButton!
    @IBOutlet weak var btnScisors: UIButton!
    @IBOutlet weak var btnPaper: UIButton!
    @IBOutlet weak var btnRandom: UIButton!
    
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
        
        if updatedGame.state == .finished {
            showAlertWith(title: "Congratz", message: "You Won", isExit: false)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        showAlertWith(title: nil, message: "Are you sure you want to exit?")
    }
        //isExit will be true every time for the first player who exit the game
        //He needs to update the state to "finished"
        private func showAlertWith(title: String?, message: String?, isExit: Bool = true) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let exit = UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
                //we need to update the other player
                if let game = self?.game, isExit {
                    DataStore.shared.updateGameStatus(game: game, newState: Game.GameState.finished.rawValue)
                }
                self?.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(exit)
            present(alert, animated: true, completion: nil)
        }
    
    @IBAction func onRock(_ sender: UIButton) {
    }
    
    @IBAction func onPaper(_ sender: UIButton) {
    }
    
    @IBAction func onScisor(_ sender: UIButton) {
    }
    
    @IBAction func onRandom(_ sender: UIButton) {
    }
}
