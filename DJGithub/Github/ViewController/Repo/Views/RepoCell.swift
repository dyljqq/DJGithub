//
//  RepoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

class RepoCell: UITableViewCell {

  lazy var backIconLabel: UILabel = {
    let label = UILabel()
    
    return label
  }()
  
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
  
  func render(with iconName: String, name: String, desc: String) {
    iconImageView.image = UIImage(named: iconName)
    nameLabel.text = name
    descLabel.text = desc
  }
  
  private func setUp() {
    contentView.addSubview(iconImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(descLabel)
    
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
  }

}
