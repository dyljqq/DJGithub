//
//  RepoPullCommitUserView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import UIKit

class RepoBranchCommitUserView: UIView {
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    return imageView
  }()
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  init() {
    super.init(frame: .zero)
    
    setUp()
  }
  
  func render(with commit: RepoBranchCommitInfo) {
    titleLabel.text = commit.commit.message
    if let committer = commit.committer {
      avatarImageView.setImage(with: committer.avatarUrl)
    }
    nameLabel.text = commit.commit.committer.name
    if let date = normalDateParser.date(from: commit.commit.committer.date) {
      dateLabel.text = "committed \(date.dateFormatString)"
    } else {
      dateLabel.text = commit.commit.committer.date
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUp() {
    addSubview(titleLabel)
    addSubview(avatarImageView)
    addSubview(nameLabel)
    addSubview(dateLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.trailing.equalTo(-12)
    }
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(5)
      make.width.height.equalTo(20)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(5)
      make.centerY.equalTo(avatarImageView)
    }
    dateLabel.snp.makeConstraints { make in
      make.leading.equalTo(nameLabel.snp.trailing).offset(5)
      make.trailing.equalTo(-12)
      make.centerY.equalTo(avatarImageView)
    }
  }
}
