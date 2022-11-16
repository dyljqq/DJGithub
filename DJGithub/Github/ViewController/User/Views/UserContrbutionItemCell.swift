//
//  UserContrbutionCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserContrbutionItemCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)

    setUp()
  }

  func render(with item: UserContributionItem) {
    contentView.backgroundColor = item.color.toColor
  }

  func setUp() {
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 2
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
