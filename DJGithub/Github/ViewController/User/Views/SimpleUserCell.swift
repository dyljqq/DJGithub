//
//  SimpleUserCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import UIKit

class SimpleUserCell: UITableViewCell {
  
  var avatarClosure: (() -> ())?
  var followClosure: (() -> ())?
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.layer.masksToBounds = true
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(tap)
    
    return imageView
  }()
  
  lazy var loginLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var urlLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var followingView: UserStatusView = {
    let view = UserStatusView()
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setUp()
  }
  
  func render(with user: UserFollowing) {
    avatarImageView.setImage(with: URL(string: user.avatarUrl))
    loginLabel.text = user.login
    urlLabel.text = user.url
    
    self.followingView.type = .follow(user.login)
    self.followingView.active = user.isFollowing
  }
  
  private func setUp() {
    contentView.backgroundColor = .white
    
    contentView.addSubview(avatarImageView)
    contentView.addSubview(loginLabel)
    contentView.addSubview(urlLabel)
    contentView.addSubview(followingView)
    
    avatarImageView.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.leading.equalTo(12)
      make.width.height.equalTo(40)
    }
    loginLabel.snp.makeConstraints { make in
      make.top.equalTo(avatarImageView)
      make.leading.equalTo(avatarImageView.snp.trailing).offset(5)
    }
    urlLabel.snp.makeConstraints { make in
      make.bottom.equalTo(avatarImageView)
      make.leading.equalTo(loginLabel)
      make.trailing.equalTo(followingView.snp.leading).offset(-5)
    }
    followingView.snp.makeConstraints { make in
      make.trailing.equalTo(contentView).offset(-12)
      make.centerY.equalTo(contentView)
      make.width.equalTo(70)
      make.height.equalTo(30)
    }
    
    followingView.touchClosure = { [weak self] in
      self?.followClosure?()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func avatarTapped() {
    avatarClosure?()
  }
}
