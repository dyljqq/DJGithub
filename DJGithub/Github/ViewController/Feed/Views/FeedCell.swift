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
    let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(tap)
    return imageView
  }()

  lazy var titleTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .clear
    textView.textColor = .textColor
    textView.font = UIFont.systemFont(ofSize: 14)
    textView.textContainerInset = .zero
    textView.isScrollEnabled = false
    textView.textContainer.lineFragmentPadding = 0
    textView.delegate = self
    textView.isEditable = false
    return textView
  }()

  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()

  var feed: Feed?

  var tappedClosure: ((FeedPushType) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setUp()
  }

  func render(with feed: Feed) {
    self.feed = feed
      avatarImageView.setImage(with: feed.thumbnail?.url, placeHolder: .defaultPersonImage)
    titleTextView.text = feed.title
    dateLabel.text = feed.formatedDate

    titleTextView.attributedText = feed.titleAttr
    titleTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBlue]
    titleTextView.snp.updateConstraints { make in
      make.height.equalTo(feed.titleHeight)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    contentView.addSubview(avatarImageView)
    contentView.addSubview(titleTextView)
    contentView.addSubview(dateLabel)

    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.width.height.equalTo(30)
    }
    titleTextView.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
      make.height.equalTo(15)
    }
    dateLabel.snp.makeConstraints { make in
      make.top.equalTo(titleTextView.snp.bottom).offset(10)
      make.leading.trailing.equalTo(titleTextView)
    }
  }

  @objc func avatarImageViewTapped() {
    if let userName = feed?.author?.name {
      self.tappedClosure?(FeedPushType.user(userName))
    }
  }

  static func cellHeight(with feed: Feed) -> CGFloat {
    return feed.titleHeight + 44
  }

}

extension FeedCell: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let arr = URL.absoluteString.components(separatedBy: "&")
    var d: [String: String] = [:]
    for a in arr {
      let b = a.components(separatedBy: "=")
      let key = b.first ?? ""
      let value = b.last ?? ""
      d[key] = value
    }

    if let type = d["type"] {
      let pushType: FeedPushType
      let value = d["value"] ?? ""
      switch type {
      case "User":
        pushType = .user(value)
      case "Repo":
        pushType = .repo(value)
      default:
        pushType = .unknown
      }

      self.tappedClosure?(pushType)
    }

    return false
  }
}
