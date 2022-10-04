//
//  RepoContentCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

fileprivate extension UIImage {
  static let fileImage: UIImage? = UIImage(named: "document")
  static let dirImage: UIImage? = UIImage(named: "directory")
}

class RepoContentCell: UITableViewCell {
  
  lazy var repoImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var arrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "arrow")
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with repoContent: RepoContent) {
    self.repoImageView.image = repoContent.image
    self.nameLabel.text = repoContent.name
    
    if !repoContent.isExpanded {
      arrowImageView.transform = CGAffineTransformMakeRotation(.pi / 2)
    } else {
      arrowImageView.transform = CGAffineTransformMakeRotation(.pi)
    }
    
    repoImageView.snp.updateConstraints { make in
      make.leading.equalTo(repoContent.deepLength * 12 + 12)
    }
  }
  
  private func setUp() {
    contentView.addSubview(repoImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(arrowImageView)
    
    repoImageView.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.leading.equalTo(12)
      make.width.height.equalTo(32)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(repoImageView.snp.trailing).offset(5)
      make.centerY.equalTo(repoImageView)
      make.trailing.equalTo(arrowImageView.snp.leading).offset(-5)
    }
    arrowImageView.snp.makeConstraints { make in
      make.centerY.equalTo(repoImageView)
      make.trailing.equalTo(contentView).offset(-12)
      make.width.height.equalTo(32)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

fileprivate extension RepoContent {
  var image: UIImage? {
    switch self.type {
    case .file: return .fileImage
    case .dir: return .dirImage
    }
  }
}
