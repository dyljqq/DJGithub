//
//  RepoBranchCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import UIKit

class RepoBranchCell: UITableViewCell {
  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "git-branch")
    return imageView
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var choosedImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "check")
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with branch: RepoBranch, selected: Bool = false) {
    titleLabel.text = branch.name
    choosedImageView.isHidden = !selected
  }
  
  private func setUp() {
    contentView.addSubview(iconImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(choosedImageView)
    
    iconImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(20)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(iconImageView.snp.trailing).offset(10)
      make.centerY.equalToSuperview()
    }
    choosedImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-12)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
