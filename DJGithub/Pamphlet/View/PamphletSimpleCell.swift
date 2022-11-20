//
//  PamphletSimpleCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

class PamphletSimpleCell: UITableViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()

  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setUp()
  }

  func render(with model: PamphletViewController.SectionItemModel?) {
    guard let model else { return }
    if let imageName = model.imageName, !imageName.isEmpty {
      iconImageView.image = UIImage(named: imageName)
      titleLabel.snp.updateConstraints { make in
        make.leading.equalTo(52)
      }
    } else {
      titleLabel.snp.updateConstraints { make in
        make.leading.equalTo(12)
      }
    }
    titleLabel.text = model.title
  }

  private func setUp() {
    contentView.backgroundColor = .white

    contentView.addSubview(titleLabel)
    contentView.addSubview(iconImageView)

    iconImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(12)
      make.width.height.equalTo(30)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(52)
      make.trailing.equalToSuperview().offset(-12)
      make.centerY.equalTo(iconImageView)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
