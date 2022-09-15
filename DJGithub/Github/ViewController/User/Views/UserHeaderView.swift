//
//  UserHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit
import Kingfisher

fileprivate class CounterView: UIView {
  
  lazy var counterLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x444444)
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  init() {
    super.init(frame: CGRect.zero)
    
    setUp()
  }
  
  func setUp() {
    addSubview(counterLabel)
    addSubview(nameLabel)
    
    counterLabel.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self.snp.centerY)
    }
    nameLabel.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.top.equalTo(self.snp.centerY)
    }
  }
  
  func render(with count: Int, name: String) {
    self.counterLabel.text = "\(count)"
    self.nameLabel.text = name
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

class UserHeaderView: UIView {
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 8
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .blue
    label.font = UIFont.systemFont(ofSize: 16)
    return label;
  }()
  
  lazy var loginLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x222222)
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var bioLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x444444)
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var joinedLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x444444)
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var horizontalLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColorFromRGB(0xf5f5f5)
    return view
  }()
  
  fileprivate lazy var repoView: CounterView = {
    return CounterView()
  }()
  
  fileprivate lazy var followersView: CounterView = {
    return CounterView()
  }()
  
  fileprivate lazy var followingView: CounterView = {
    return CounterView()
  }()
  
  init() {
    super.init(frame: CGRect.zero)
    
    setUp()
  }
  
  func render(with user: User) {
    avatarImageView.kf.setImage(with: URL(string: user.avatarUrl))
    nameLabel.text = user.name
    loginLabel.text = "(\(user.login))"
    bioLabel.text = user.bio
    if let joined = user.createdAt.split(separator: "T").first {
      joinedLabel.text = "Joined on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Joined on \(user.createdAt)"
    }
    repoView.render(with: user.publicRepos, name: "Repos")
    followersView.render(with: user.followers, name: "Followers")
    followingView.render(with: user.following, name: "Following")
  }
  
  private func setUp() {
    self.backgroundColor = .white
    addSubview(avatarImageView)
    addSubview(nameLabel)
    addSubview(loginLabel)
    addSubview(bioLabel)
    addSubview(joinedLabel)
    
    addSubview(horizontalLine)
    addSubview(repoView)
    addSubview(followersView)
    addSubview(followingView)
    
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(12)
      make.width.equalTo(60)
      make.height.equalTo(60)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.top.equalTo(avatarImageView)
    }
    loginLabel.snp.makeConstraints { make in
      make.top.equalTo(avatarImageView)
      make.leading.equalTo(nameLabel.snp.trailing)
      make.trailing.equalTo(-12)
    }
    bioLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(5)
      make.leading.equalTo(nameLabel)
      make.trailing.equalTo(loginLabel)
    }
    joinedLabel.snp.makeConstraints { make in
      make.bottom.equalTo(avatarImageView)
      make.trailing.equalTo(bioLabel)
      make.leading.equalTo(bioLabel)
    }
    horizontalLine.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerX.equalTo(self)
      make.height.equalTo(0.5)
      make.top.equalTo(avatarImageView.snp.bottom).offset(12)
    }
    repoView.snp.makeConstraints { make in
      make.width.equalTo(self).dividedBy(3)
      make.height.equalTo(44)
      make.leading.equalTo(self)
      make.top.equalTo(horizontalLine.snp.bottom).offset(5)
    }
    followersView.snp.makeConstraints { make in
      make.width.height.top.equalTo(repoView)
      make.leading.equalTo(repoView.snp.trailing)
    }
    followingView.snp.makeConstraints { make in
      make.width.height.top.equalTo(repoView)
      make.leading.equalTo(followersView.snp.trailing)
    }
  }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

}
