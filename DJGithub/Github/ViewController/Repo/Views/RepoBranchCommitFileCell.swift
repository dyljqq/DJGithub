//
//  RepoBranchCommitFileCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import UIKit

class RepoBranchCommitFileCell: UITableViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textGrayColor
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with file: RepoPullFile) {
    titleLabel.text = file.filename
    descLabel.text = "\(file.additions) additions and \(file.deletions) deletions."
  }
  
  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(descLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
    }
    descLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
