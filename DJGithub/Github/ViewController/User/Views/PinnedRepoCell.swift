//
//  PinnedRepoCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/26.
//

import UIKit

class PinnedRepoCell: UICollectionViewCell {

  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textColor = .lightBlue
    return label
  }()

  lazy var repoIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "book")
    return imageView
  }()

  lazy var updatedLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .textGrayColor
    return label
  }()

  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textColor
    label.numberOfLines = 2
    return label
  }()

  lazy var languageColorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 7
    return view
  }()

  lazy var languageLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()

  lazy var starImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "star")
    return imageView
  }()

  lazy var starCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .textColor
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  func render(with pinnedItem: PinnedRepoNode) {
    nameLabel.text = pinnedItem.name
    descLabel.text = pinnedItem.description ?? "No Description Provided."
    languageColorView.backgroundColor = pinnedItem.primaryLanguage?.color.toColor
    languageLabel.text = pinnedItem.primaryLanguage?.name
    if pinnedItem.viewerHasStarred {
      starImageView.image = UIImage(named: "stared")
    } else {
      starImageView.image = UIImage(named: "star")
    }
    starCountLabel.text = "\(pinnedItem.stargazers.totalCount)"
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 5
    contentView.layer.masksToBounds = true

    contentView.addSubview(repoIconImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(updatedLabel)
    contentView.addSubview(descLabel)
    contentView.addSubview(languageColorView)
    contentView.addSubview(languageLabel)
    contentView.addSubview(starImageView)
    contentView.addSubview(starCountLabel)

    repoIconImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(12)
      make.width.height.equalTo(20)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(repoIconImageView.snp.trailing).offset(10)
      make.centerY.equalTo(repoIconImageView)
    }
    descLabel.snp.makeConstraints { make in
      make.top.equalTo(repoIconImageView.snp.bottom).offset(10)
      make.leading.equalTo(repoIconImageView)
      make.trailing.equalToSuperview().offset(-12)
    }
    languageColorView.snp.makeConstraints { make in
      make.leading.equalTo(repoIconImageView)
      make.width.height.equalTo(14)
      make.bottom.equalToSuperview().offset(-10)
    }
    languageLabel.snp.makeConstraints { make in
      make.centerY.equalTo(languageColorView)
      make.leading.equalTo(languageColorView.snp.trailing).offset(5)
    }
    starImageView.snp.makeConstraints { make in
      make.width.height.equalTo(20)
      make.centerY.equalTo(languageColorView)
      make.leading.equalTo(languageLabel.snp.trailing).offset(20)
    }
    starCountLabel.snp.makeConstraints { make in
      make.centerY.equalTo(languageColorView)
      make.leading.equalTo(starImageView.snp.trailing).offset(5)
    }
  }
}
