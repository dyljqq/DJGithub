//
//  FeedCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import UIKit

class FeedCell: UITableViewCell {
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with feed: Feed) {
    avatarImageView.setImage(with: feed.thumbnail?.url)
    titleLabel.text = feed.title
    let dateString: String?
    if let published = feed.published?.components(separatedBy: "T").first {
      dateString = published
    } else {
      dateString = feed.published
    }
    dateLabel.text = dateString
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUp() {
    contentView.addSubview(avatarImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(dateLabel)
    
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.width.height.equalTo(30)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
    }
    dateLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
      make.leading.trailing.equalTo(titleLabel)
    }
  }
  
  static func cellHeight(with title: String) -> CGFloat {
    let rect = (title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 64, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)],
      context: nil
    )
    return rect.height + 44
  }

}
