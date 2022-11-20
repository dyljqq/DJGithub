//
//  PamphletResourceCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

class PamphletResourceCell: UITableViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()

  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .textGrayColor
    label.numberOfLines = 0
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setUp()
  }

  func render(with model: PamphletResourceModel) {
    titleLabel.text = model.title
    contentLabel.text = model.desc
  }

  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(contentLabel)

    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
    }
    contentLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.bottom.equalTo(-10)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
