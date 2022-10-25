//
//  RepoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

class RepoCell: UITableViewCell {
  enum CellType {
    case blank, language(String, String), issues(String), pull(String), branch(String), readme
  }
  
  var reloadClosure: (() -> ())?
  
  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var reloadImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "repo_reload")
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    
    return imageView
  }()
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render(with type: CellType) {
    iconImageView.image = UIImage(named: type.imageName)
    nameLabel.text = type.name
    
    if type.showReload {
      descLabel.isHidden = true
      reloadImageView.isHidden = false
    } else {
      descLabel.isHidden = false
      reloadImageView.isHidden = true
      descLabel.text = type.desc
    }
  }
  
  @objc func reloadAction() {
    reloadClosure?()
  }
  
  private func setUp() {
    contentView.addSubview(iconImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(descLabel)
    contentView.addSubview(reloadImageView)
    
    iconImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerY.equalTo(contentView)
      make.width.height.equalTo(20)
    }
    nameLabel.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.leading.equalTo(iconImageView.snp.trailing).offset(12)
    }
    descLabel.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.centerY.equalTo(contentView)
    }
    reloadImageView.snp.makeConstraints { make in
      make.trailing.equalTo(-16)
      make.centerY.equalTo(contentView)
      make.width.height.equalTo(20)
    }
  }

}

extension RepoCell.CellType {
  var height: CGFloat {
    switch self {
    case .blank: return 12
    default: return 44
    }
  }

  var imageName: String {
    switch self {
    case .language: return "coding"
    case .issues: return "issue"
    case .pull: return "pull-request"
    case .branch: return "git-branch"
    case .readme: return "book"
    default: return ""
    }
  }
  
  var name: String {
    switch self {
    case .language(let language, _): return language
    case .issues: return "Issues"
    case .pull: return "Pull Requests"
    case .branch: return "Branches"
    case .readme: return "README"
    default: return ""
    }
  }
  
  var desc: String {
    switch self {
    case .language(_, let desc): return desc
    case .issues(let desc): return desc
    case .branch(let desc): return desc
    case .pull(let desc): return desc
    default: return ""
    }
  }

  var showReload: Bool {
    switch self {
    case .readme: return true
    default: return false
    }
  }
}
