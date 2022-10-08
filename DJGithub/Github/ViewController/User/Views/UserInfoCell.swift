//
//  UserInfoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/8.
//

import UIKit

class UserInfoCell: UITableViewCell {
  
  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .left
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with name: String, content: String?) {
    self.nameLabel.text = "\(name):"
    self.contentLabel.text = content
  }
  
  private func setUp() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(contentLabel)

    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerY.equalToSuperview()
    }
    contentLabel.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.leading.equalTo(nameLabel.snp.trailing).offset(10)
      make.centerY.equalTo(nameLabel)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
