//
//  HomeViewController.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var loadingView: LoadingView?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveGameRequest(_:)), name: Notification.Name("DidRecieveGameRequestNotification"), object: nil)
        setupTable()
        getUsers()
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
    
    private func setupTable() {
        tableView.dataSource = self
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
            self.declineRequest(gameRequest: gameRequest)
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
        
        DataStore.shared.checkForExistingGame(toUser: userId, fromUser: localUserId) { (exists, error) in
            if let error = error {
                print(error.localizedDescription)
                print("Error checking for game, try again later")
                return
            }
            
            if !exists {
                DataStore.shared.startGameRequest(userID: userId) { [weak self] (request, error) in
                    if request != nil {
                        DataStore.shared.setGameRequestDelitionListener()
                        self?.setupLoadingView(me: localUser, opponent: user, request: request)
                    }
                }
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
        
        loadingView = LoadingView(me: me, opponent: opponent, request: request)
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
