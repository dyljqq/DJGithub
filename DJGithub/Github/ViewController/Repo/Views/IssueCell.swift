//
//  IssueCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

class IssueCell: UITableViewCell {

  lazy var stateImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .blue
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 3
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 10)
    return label
  }()
  
  lazy var updateAtLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 10)
    return label
  }()

  lazy var messageImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "message")
    return imageView
  }()
  
  lazy var commentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 10)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with issueLayout: IssueLayout) {
    let issue = issueLayout.issue
    stateImageView.image = UIImage(named: issueLayout.imageName)
    titleLabel.text = issueLayout.title

    if let avatarUrlString = issue.user?.avatarUrl {
      avatarImageView.setImage(with: URL(string: avatarUrlString))
    }
    nameLabel.text = issue.user?.login
    if let updatedAt = issue.updatedAt.split(separator: "T").first {
      updateAtLabel.text = "\(String(describing: updatedAt))"
    } else {
      updateAtLabel.text = "\(issue.updatedAt)"
    }
    commentsLabel.text = "\(issue.comments ?? 0)"
  }
  
  private func setUp() {
    contentView.addSubview(stateImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(avatarImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(updateAtLabel)
    contentView.addSubview(messageImageView)
    contentView.addSubview(commentsLabel)
    
    stateImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(12)
      make.width.height.equalTo(16)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(stateImageView.snp.trailing).offset(5)
      make.top.equalTo(stateImageView)
      make.trailing.equalTo(contentView).offset(-12)
    }
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(5)
      make.width.height.equalTo(12)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(5)
      make.centerY.equalTo(avatarImageView)
    }
    commentsLabel.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.centerY.equalTo(avatarImageView)
    }
    messageImageView.snp.makeConstraints { make in
      make.centerY.equalTo(avatarImageView)
      make.trailing.equalTo(self.commentsLabel.snp.leading).offset(-5)
      make.width.height.equalTo(10)
    }
    updateAtLabel.snp.makeConstraints { make in
      make.trailing.equalTo(messageImageView.snp.leading).offset(-12)
      make.centerY.equalTo(avatarImageView)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
