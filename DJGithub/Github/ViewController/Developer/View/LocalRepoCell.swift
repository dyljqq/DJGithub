//
//  LocalRepoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/7.
//

import UIKit

class LocalRepoCell: UITableViewCell {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 0
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with repo: LocalRepo) {
    self.titleLabel.text = repo.id
    self.descLabel.text = repo.description
  }
  
  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(descLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(10)
      make.leading.equalTo(12)
    }
    descLabel.snp.makeConstraints { make in
      make.bottom.equalTo(-10)
      make.leading.equalTo(titleLabel)
      make.trailing.equalTo(-12)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
