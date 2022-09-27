//
//  SimpleUserCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import UIKit

class SimpleUserCell: UITableViewCell {
  
  var avatarClosure: (() -> ())? = nil
  
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
  
  lazy var followingButton: UIButton = {
    let button = UIButton()
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    button.layer.cornerRadius = 15
    button.addTarget(self, action: #selector(followAction), for: .touchUpInside)
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setUp()
  }
  
  func render(with user: UserFollowing) {
    avatarImageView.kf.setImage(with: URL(string: user.avatarUrl))
    loginLabel.text = user.login
    urlLabel.text = user.url
    
    let title: String
    let font: UIFont
    if user.isFollowing {
      title = "UnFollow"
      followingButton.setTitleColor(.white, for: .normal)
      followingButton.backgroundColor = .lightBlue
      font = UIFont.systemFont(ofSize: 14, weight: .bold)
    } else {
      title = "Follow"
      followingButton.setTitleColor(.blue, for: .normal)
      followingButton.backgroundColor = .backgroundColor
      font = UIFont.systemFont(ofSize: 12)
    }
    followingButton.titleLabel?.font = font
    followingButton.setTitle(title, for: .normal)
    
    DispatchQueue.global().async {
      let width = (title as NSString).boundingRect(with: CGSize(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size.width + 16
      DispatchQueue.main.async {
        self.followingButton.snp.updateConstraints { make in
          make.width.equalTo(width)
        }
      }
    }
  }
  
  private func setUp() {
    contentView.backgroundColor = .white
    
    contentView.addSubview(avatarImageView)
    contentView.addSubview(loginLabel)
    contentView.addSubview(urlLabel)
    contentView.addSubview(followingButton)
    
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
      make.trailing.equalTo(followingButton.snp.leading).offset(-5)
    }
    followingButton.snp.makeConstraints { make in
      make.trailing.equalTo(contentView).offset(-12)
      make.centerY.equalTo(contentView)
      make.width.equalTo(70)
      make.height.equalTo(30)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func followAction() {
    
  }
  
  @objc func avatarTapped() {
    avatarClosure?()
  }
}
