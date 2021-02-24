//
//  UserCell.swift
//  iOSGame
//
//  Created by Stefan Minchevski on 1.2.21.
//

import UIKit
import SnapKit

protocol UserCellDelegate: class {
    func requestGameWith(user: User)
}

class UserCell: UITableViewCell {
    
     lazy var lblUsername: UILabel = {
       var label = UILabel()
        label.textColor = UIColor(hex: "#3545C8")
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(UIImage(named: "btnPlay"), for: .normal)
        button.addTarget(self, action: #selector(onStart), for: .touchUpInside)
        return button
    }()
    
    private lazy var holderView: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()

    private var user: User?
    weak var delegate: UserCellDelegate?
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(holderView)
        holderView.addSubview(lblUsername)
        holderView.addSubview(btnStart)
        holderView.addSubview(userImage)
        
        holderView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        
        userImage.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(50)
        }
        
        lblUsername.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).offset(15)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        
        btnStart.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(50)
        }
    }
    
    @objc private func onStart() {
        guard let user = user else { return }
        delegate?.requestGameWith(user: user)
//        btnStart.isHidden = true
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
    }
    
    func setData(user: User) {
        self.user = user
        lblUsername.text = user.username
//        guard let imageName = user.avatarImage else { return }
        
        if let imageName = user.avatarImage, let image = UIImage(named: imageName) {
            userImage.image = image
        } else {
            userImage.image = UIImage(named: "avatarOne")
        }
    }
}
