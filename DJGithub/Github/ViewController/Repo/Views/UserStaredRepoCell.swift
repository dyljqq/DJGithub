//
//  UserStaredRepoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

fileprivate class IconAndLabelView: UIView {
  
  enum ViewType {
    case language(UIColor, String)
    case star(String, String)
    case fork(String, String)
  }
  
  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  init() {
    super.init(frame: CGRect.zero)
    
    setUp()
  }
  
  func render(with type: ViewType) {
    if case ViewType.language(let color, let content) = type {
      iconImageView.layer.cornerRadius = 6
      iconImageView.backgroundColor = color
      contentLabel.text = content
    } else {
      switch type {
      case .star(let iconName, let content):
        iconImageView.image = UIImage(named: iconName)
        contentLabel.text = content
      case .fork(let iconName, let content):
        iconImageView.image = UIImage(named: iconName)
        contentLabel.text = content
      default:
        break
      }
    }
  }
  
  func setUp() {
    addSubview(iconImageView)
    addSubview(contentLabel)
    
    iconImageView.snp.makeConstraints { make in
      make.centerY.equalTo(self)
      make.leading.equalTo(0)
      make.width.height.equalTo(12)
    }
    contentLabel.snp.makeConstraints { make in
      make.leading.equalTo(iconImageView.snp.trailing).offset(5)
      make.centerY.equalTo(iconImageView)
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

class UserStaredRepoCell: UITableViewCell {
  
  var repo: Repo?
  
  var avatarImageViewTappedClosure: ((String) -> Void)?

  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 4
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  lazy var repoNameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .blue
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var updatedAtLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  fileprivate lazy var languageView: IconAndLabelView = {
    return IconAndLabelView()
  }()
  
  fileprivate lazy var starView: IconAndLabelView = {
    return IconAndLabelView()
  }()
  
  fileprivate lazy var forkView: IconAndLabelView = {
    return IconAndLabelView()
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with repo: Repo) {
    self.repo = repo
    avatarImageView.setImage(with: URL(string: repo.owner?.avatarUrl ?? ""))
    repoNameLabel.text = repo.fullName
    descLabel.text = repo.desc
    
    if let updatedAt = repo.updatedAt.split(separator: "T").first {
      updatedAtLabel.text = "Updated on \(String(describing: updatedAt))"
    } else {
      updatedAtLabel.text = "Updated on \(repo.updatedAt)"
    }
    
    let color: UIColor
    if let hex = LanguageManager.mapping[repo.language ?? "Unknown"] {
      color = hex.toColor ?? .blue
    } else {
      color = .blue
    }
    languageView.render(with: .language(color, repo.language ?? "Unknown"))
    starView.render(with: .star("stared", repo.stargazersCount.toGitNum))
    forkView.render(with: .fork("git-branch", repo.forksCount.toGitNum))
  }
  
  class func cellHeight(by repo: Repo) -> CGFloat {
    let descLabelHeight = NSString(string: repo.desc).boundingRect(with: CGSize(width: FrameGuide.screenWidth - 64, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil).size.height
    return 82 + descLabelHeight
  }
  
  @objc func avatarImageViewTapped() {
    if let repo = repo, let owner = repo.owner {
      avatarImageViewTappedClosure?(owner.login)
    }
  }
  
  func setUp() {
    contentView.addSubview(avatarImageView)
    contentView.addSubview(repoNameLabel)
    contentView.addSubview(descLabel)
    contentView.addSubview(updatedAtLabel)
    contentView.addSubview(languageView)
    contentView.addSubview(starView)
    contentView.addSubview(forkView)
    
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.width.height.equalTo(30)
    }
    repoNameLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.top.equalTo(avatarImageView)
      make.trailing.equalTo(contentView).offset(-12)
    }
    descLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(repoNameLabel)
      make.top.equalTo(repoNameLabel.snp.bottom).offset(6)
      make.trailing.equalTo(repoNameLabel)
    }
    updatedAtLabel.snp.makeConstraints { make in
      make.top.equalTo(descLabel.snp.bottom).offset(6)
      make.leading.trailing.equalTo(repoNameLabel)
    }
    languageView.snp.makeConstraints { make in
      make.leading.equalTo(repoNameLabel)
      make.height.equalTo(20)
      make.width.equalTo(100)
      make.top.equalTo(updatedAtLabel.snp.bottom).offset(5)
    }
    starView.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.leading.equalTo(languageView.snp.trailing).offset(40)
      make.top.height.equalTo(languageView)
    }
    forkView.snp.makeConstraints { make in
      make.top.height.equalTo(languageView)
      make.width.equalTo(60)
      make.leading.equalTo(starView.snp.trailing).offset(40)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
