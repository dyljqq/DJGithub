//
//  RssFeedLatestCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/8.
//

import UIKit

struct RssFeedLatestCellModel {
  let title: String
  let from: String
  let feedId: Int
  
  let cellSize = CGSize(width: 300, height: 69)
  
  init(title: String, from: String, feedId: Int) {
    self.title = title
    self.from = from
    self.feedId = feedId
  }
}

class RssFeedLatestCell: UICollectionViewCell {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var fromLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setUp()
  }
  
  func render(with model: RssFeedLatestCellModel) {
    titleLabel.text = model.title
    fromLabel.text = model.from
  }
  
  private func setUp() {
    contentView.layer.cornerRadius = 8
    contentView.clipsToBounds = true
    contentView.backgroundColor = .white
    contentView.addSubview(titleLabel)
    contentView.addSubview(fromLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
    }
    fromLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(titleLabel)
      make.bottom.equalTo(-10)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
