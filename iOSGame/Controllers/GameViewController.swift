//
//  GameViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    

    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var btnRock: UIButton!
    @IBOutlet weak var btnScisors: UIButton!
    @IBOutlet weak var btnPaper: UIButton!
    @IBOutlet weak var btnRandom: UIButton!
    @IBOutlet weak var bloodImage: UIImageView!
    
    @IBOutlet weak var opponentHandImage: UIImageView!
    @IBOutlet weak var myHandImage: UIImageView!
    
    @IBOutlet weak var myHandBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHandTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var myHandHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHeightConstraint: NSLayoutConstraint!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bloodImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        setConstraintsForSmallerDevices()
        setGameStatusListener()
        
        if let game = game {
            shouldEnableButtons(enable: game.state == .inprogress)
//            if game.state == .inprogress {
//                shouldEnableButtons(enable: true)
//            } else {
//                shouldEnableButtons(enable: false)
//            }
        }
    }
    
    private func setConstraintsForSmallerDevices() {
        // 420 Height for iPhone X
        if DeviceType.isIphone8OrSmaller {
            myHandHeightConstraint.constant = 320
            opponentHeightConstraint.constant = 320
        } else if DeviceType.isIphoneXOrBigger {
            myHandHeightConstraint.constant = 420
            opponentHeightConstraint.constant = 420
        }
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
        shouldEnableButtons(enable: updatedGame.state == .inprogress)
        lblGameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        animateMoves(game: updatedGame)
        return
        
//        checkForWinner(game: updatedGame)
//
//        if updatedGame.state == .finished && game?.winer == nil {
//            DataStore.shared.removeGameListener()
//            game?.winer = updatedGame.players.filter({ $0.id == DataStore.shared.localUser?.id }).first
//            DataStore.shared.updateGameMoves(game: self.game!)
//            continueToResults()
//        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        btnRock.isEnabled = enable
        btnPaper.isEnabled = enable
        btnRandom.isEnabled = enable
        btnScisors.isEnabled = enable
    }
    
    private func animateMoves(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id,
              let opponentUser = game.players.filter ({ $0.id != localUserId }).first,
              let opponentUserId = opponentUser.id else { return }
        
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove != .idle && otherMove != .idle {
            animateHandTo(move: myMove, isMyHand: true)
            animateHandTo(move: otherMove, isMyHand: false)
            
            // We will animate both hands at the same time back on board
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.myHandBottomConstraint.constant = Moves.minimumY(isOpponent: false)
                self.opponentHandTopConstraint.constant = Moves.minimumY(isOpponent: true)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { (finished) in
                    if finished {
                        self.checkForWinner(game: game)
                    }
                }
            }
            return
        }
    }
    
    private func animateHandTo(move: Moves?, isMyHand: Bool) {
        guard let move = move, move != .idle else { return }
        
        if isMyHand {
            myHandBottomConstraint.constant = Moves.maximumY
        } else {
            opponentHandTopConstraint.constant = Moves.maximumY
        }
        UIView.animate(withDuration: 0.2) {
            // closure for animation
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            // closure for when animation is done, finished flag argument (flag == bool)
            if finished {
                if isMyHand {
                    self.myHandImage.image = UIImage(named: move.imageName(isOpponent: !isMyHand))
                } else {
                    self.opponentHandImage.image = UIImage(named: move.imageName(isOpponent: false))
                }
            }
        }
    }
    
//    private func animateMyHandTo(move: Moves?) {
//        guard let move = move, move != .idle else { return }
//
//        myHandBottomConstraint.constant = Moves.maximumY
//        UIView.animate(withDuration: 0.2) {
//            // closure for animation
//            self.view.layoutIfNeeded()
//        } completion: { (finished) in
//            // closure for when animation is done, finished flag argument (flag == bool)
//            if finished {
//                self.myHandImage.image = UIImage(named: move.imageName(isOpponent: false))
//            }
//        }
//    }
//
//    private func animateOtherHandTo(move: Moves?) {
//        guard let move = move, move != .idle else { return }
//
//        opponentHandTopConstraint.constant = Moves.maximumY
//        UIView.animate(withDuration: 0.2) {
//            // closure for animation
//            self.view.layoutIfNeeded()
//        } completion: { (finished) in
//            // closure for when animation is done, finished flag argument (flag == bool)
//            if finished {
//                self.opponentHandImage.image = UIImage(named: move.imageName(isOpponent: true))
//            }
//        }
//    }

    
    private func checkForWinner(game:Game) {
        guard let localUserId = DataStore.shared.localUser?.id,
              let opponentUser = game.players.filter ({ $0.id != localUserId }).first,
              let opponentUserId = opponentUser.id else { return }
        
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove == .idle && otherMove == .idle {
            // Both havent picked move yet
        } else if myMove == .idle {
            // Still waiting
        } else if otherMove == .idle {
            // Still waiting
        } else {
            //we have both pics
            if let mMove = myMove, let oMove = otherMove {
                
                //This if will succeed only if the local user is winner,
                //The osther user will get listener for the game with updated winner property
                let space = (opponentHandImage.frame.origin.y + opponentHandImage.frame.height) - myHandImage.frame.origin.y
                if mMove > oMove {
                    //winner is mMove
                    
                    
                    UIView.animate(withDuration: 0.5) {
                        self.myHandImage.transform = CGAffineTransform(translationX: 0, y: -space)
                    } completion: { (finished) in
                        if finished {
                            UIView.animate(withDuration: 0.5) {
                                self.bloodImage.transform = .identity
                                self.myHandImage.transform = .identity
                            } completion: { (finished) in
                                if finished {
                                    self.setWinner(game: game)
                                }
                            }
                        }
                    }  
                } else {
                    UIView.animate(withDuration: 0.5) {
                        self.opponentHandImage.transform = CGAffineTransform(translationX: 0, y: space)
                    } completion: { (finished) in
                        if finished {
                            UIView.animate(withDuration: 0.5) {
                                self.bloodImage.transform = .identity
                                self.opponentHandImage.transform = .identity
                            } completion: { (finished) in
                                if finished {
//                                    self.setWinner(game: game)
                                }
                            }
                        }
                    }
//                    if game.winer != nil {
//                        self.continueToResults()
//                    }
                }
            }
        }
    }
    
    private func setWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DataStore.shared.removeGameListener()
            self.game?.winer = game.players.filter({ $0.id == localUserId }).first
            self.game?.state = .finished
            DataStore.shared.updateGameMoves(game: self.game!)
            self.continueToResults()
        }
    }
    
    func continueToResults() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "FightResultViewController") as! FightResultViewController
        controller.game = game
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
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
        sender.isSelected = true
        pickedMove(.rock)
    }
    
    @IBAction func onPaper(_ sender: UIButton) {
        sender.isSelected = true
        pickedMove(.paper)
    }
    
    @IBAction func onScisor(_ sender: UIButton) {
        sender.isSelected = true
        pickedMove(.scissors)
    }
    
    @IBAction func onRandom(_ sender: UIButton) {
       
        // let choices: [Moves] = [.paper, .rock, .scissors]
        let choices: [Moves] = Moves.allCases.filter { $0 != .idle }
        guard let move = choices.randomElement() else { return }
        selectButtonFor(move: move)
        pickedMove(move)
        // More Swifty way of doing things
        // game.moves[localUserId] = Moves.allCases.filter { $0 != .idle }.randomElement()
    }
    
    private func selectButtonFor(move: Moves) {
        switch move {
        case .idle:
            return
        case .paper:
            btnPaper.isSelected = true
        case .rock:
            btnRock.isSelected = true
        case .scissors:
            btnScisors.isSelected = true
        }
    }
    
    private func pickedMove(_ move: Moves) {
        guard let localUserId = DataStore.shared.localUser?.id,
              var game = game else {
            return
        }
        
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
    }
}
