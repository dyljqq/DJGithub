//
//  LocalDeveloperCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class LocalDeveloperCell: UITableViewCell {
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var titleLabel: UILabel = {
    let label: UILabel = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var desLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var followView: FollowUserStatusView = {
    let view = FollowUserStatusView(layoutLay: .auto)
    return view
  }()
  
  var touchFollowViewClosure: (() -> ())?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with developer: LocalDeveloper) {
    avatarImageView.setImage(with: developer.avatarUrl, placeHolder: UIImage.defaultPersonImage)
    titleLabel.text = developer.name
    desLabel.text = developer.des ?? "None desc"
    
    followView.render(with: developer.name)
  }
  
  private func setUp() {
    contentView.addSubview(avatarImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(desLabel)
    contentView.addSubview(followView)
    
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(16)
      make.centerY.equalTo(contentView)
      make.width.height.equalTo(40)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(5)
      make.top.equalTo(avatarImageView)
      make.trailing.equalTo(-16)
    }
    desLabel.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.bottom.equalTo(avatarImageView)
      make.trailing.equalTo(followView.snp.leading).offset(-12)
    }
    followView.snp.makeConstraints { make in
      make.trailing.equalTo(contentView).offset(-12)
      make.centerY.equalTo(contentView)
      make.width.equalTo(70)
      make.height.equalTo(30)
    }
    
    followView.touchClosure = { [weak self] in
      self?.touchFollowViewClosure?()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
