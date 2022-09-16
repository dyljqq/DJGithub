//
//  UserCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserCell: UITableViewCell {
  
  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func setUp() {
    contentView.addSubview(iconImageView)
    contentView.addSubview(contentLabel)
    
    iconImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerY.equalTo(contentView)
      make.width.height.equalTo(20)
    }
    contentLabel.snp.makeConstraints { make in
      make.centerY.equalTo(iconImageView)
      make.leading.equalTo(iconImageView.snp.trailing).offset(10)
    }
  }
  
  func render(with iconName: String, content: String, contentColor: UIColor) {
    iconImageView.image = UIImage(named: iconName)
    contentLabel.text = content
    contentLabel.textColor = contentColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
