//
//  LocalDeveloperCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class LocalDeveloperCell: UITableViewCell {
  
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
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with developer: LocalDeveloper) {
    titleLabel.text = developer.id
    desLabel.text = developer.des ?? "None desc"
  }
  
  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(desLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(16)
      make.bottom.equalTo(contentView.snp.centerY).offset(-3)
      make.trailing.equalTo(-16)
    }
    desLabel.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.top.equalTo(contentView.snp.centerY).offset(3)
      make.trailing.equalTo(titleLabel)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
