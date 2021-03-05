//
//  HomeViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import UIKit

class HomeViewController: UIViewController, AlertPresenter {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHolderView: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var tableHolderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHolderView: UIView!
    
    
    var loadingView: LoadingView?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPushNotifications()
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveGameRequest(_:)), name: Notification.Name("DidRecieveGameRequestNotification"), object: nil)
        setupTable()
        getUsers()
        setupAvatarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataStore.shared.setUsersListener {
            self.getUsers()
        }
        
        DataStore.shared.setGameRequestListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataStore.shared.removeUsersListener()
        DataStore.shared.removeGameRequestListener()
    }
    
    private func requestPushNotifications() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.requestNotificationsPermision()
    }
    
    private func setupAvatarView() {
        let avatarView = AvatarView(state: .imageAndName)
        avatarHolderView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(5)
        }
        
        avatarView.username = DataStore.shared.localUser?.username
        avatarView.image = DataStore.shared.localUser?.avatarImage
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
    
    @objc private func didReceiveGameRequest(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:GameRequest] else { return }
        guard let gameRequest = userInfo["GameRequest"] else { return }
    
        let fromUsername = gameRequest.fromUsername ?? ""
        
        let alert = UIAlertController(title: "Game Request",
                                      message: "\(fromUsername) invited you for a game",
                                      preferredStyle: .alert)
        
        let accept = UIAlertAction(title: "Accept", style: .default) { _ in
            self.acceptGameRequest(gameRequest)
        }
        
        let decline = UIAlertAction(title: "Decline", style: .cancel) { _ in
            self.declineRequest(gameRequest: gameRequest)
        }
        
        alert.addAction(accept)
        alert.addAction(decline)
        present(alert, animated: true, completion: nil)
    }
    
    private func getUsers() {
        DataStore.shared.getAllUsers { (users, error) in
            if let users = users {
                self.users = users.filter({$0.id != DataStore.shared.localUser?.id})
                self.tableView.reloadData()
            }
        }
    }
    
    private func declineRequest(gameRequest: GameRequest) {
        DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
    }
    
    private func acceptGameRequest(_ gameRequest: GameRequest) {
        guard let localUser = DataStore.shared.localUser else { return }
        
        DataStore.shared.getUserWithId(id: gameRequest.from) { [weak self] (user, error) in
            if let error  = error{
                print(error.localizedDescription)
                return
            }
            
            if let user = user {
                DataStore.shared.createGame(players: [localUser, user]) { (game, error) in
                    DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let game = game {
                        self?.enterGame(game)
                    }
                }
            }
        }
    }
    
    private func enterGame(_ game: Game,_ shouldUpdateGame: Bool = false) {
        DataStore.shared.removeGameListener()
        
        if shouldUpdateGame {
            var newGame = game
            newGame.state = .inprogress
            DataStore.shared.updateGameStatus(game: newGame, newState: Game.GameState.inprogress.rawValue)
            performSegue(withIdentifier: "GameSegue", sender: newGame)
        } else {
            performSegue(withIdentifier: "GameSegue", sender: game)
        }
    }
    
    @IBAction func onExpand(_ sender: UIButton) {
        
        let isExpanded = tableHolderBottomConstraint.constant == 0
        
        self.btnExpand.setImage(UIImage(named: isExpanded ? "expandUp" : "expandDown"), for: .normal)
        
        tableHolderBottomConstraint.constant = isExpanded ? tableHolderView.frame.height : 0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            //Animating frames instead of constraints
            // self.tableHolderView.frame.origin = CGPoint(x: tableHolderView.frame.origin.x,
            //                                             y: -tableHolderView.frame.size.height)
        } completion: { completed in
            if completed {
                //animation is completed
            }
        }
    }
}

//MARK: - Navigation
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "GameSegue" else { return }
        let gameController = segue.destination as! GameViewController
        gameController.game = sender as? Game
    }
}

//MARK: - UITableView DataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier) as! UserCell
        let user = users[indexPath.row]
        cell.setData(user: user)
        cell.delegate = self
        return cell
    }
}

//MARK: - UserCell Delegate
extension HomeViewController: UserCellDelegate {
    func requestGameWith(user: User) {
        guard let userId = user.id,
              let localUser = DataStore.shared.localUser,
              let localUserId = localUser.id else { return }
        
        DataStore.shared.checkForExistingGameRequest(toUser: userId, fromUser: localUserId) { [weak self] (exists, error) in
            if let error = error {
                print(error.localizedDescription)
                print("Error checking for game, try again later")
                return
            }
            
            if !exists {
                self?.checkForOngoingGame(userId: userId, localUser: localUser, opponent: user)
            }
        }
    }
    
    func checkForOngoingGame(userId: String, localUser: User, opponent: User) {
        DataStore.shared.checkForOngoingGameWith(userId: userId) { [weak self] (userInGame, error) in
            if !userInGame {
                self?.sendGameRequestsTo(userId: userId, localUser: localUser, opponent: opponent)
            } else {
                //Show user already in game alert
            }
        }
    }
    
    func sendGameRequestsTo(userId: String, localUser: User, opponent: User) {
        DataStore.shared.startGameRequest(userID: userId) { [weak self] (request, error) in
            if request != nil {
                self?.setupLoadingView(me: localUser, opponent: opponent , request: request)
            }
        }
    }
}

//MARK: - Loading View Handling
extension HomeViewController {
    
    func setupLoadingView(me: User, opponent: User, request: GameRequest?) {
        if loadingView != nil {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
        
        loadingView = LoadingView(me: me, opponent: opponent, request: request, alertPresenter: self)
        loadingView?.gameAccepted = { [weak self] game in
            self?.enterGame(game, true)
        }
        
        view.addSubview(loadingView!)
        loadingView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}



