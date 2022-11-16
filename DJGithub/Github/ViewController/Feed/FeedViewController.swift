//
//  FeedViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit
import WebKit

class FeedHeaderView: UIView {

  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.layer.masksToBounds = true
    return imageView
  }()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textColor
    return label
  }()

  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .textGrayColor
    return label
  }()

  init() {
    super.init(frame: .zero)

    setUp()
  }

  func render(with feed: Feed) {
    avatarImageView.setImage(with: feed.thumbnail?.url)
    titleLabel.text = feed.title
    dateLabel.text = feed.formatedDate
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    addSubview(avatarImageView)
    addSubview(titleLabel)
    addSubview(dateLabel)

    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.width.height.equalTo(30)
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.top.equalTo(avatarImageView)
      make.trailing.equalTo(-12)
    }
    dateLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
    }
  }

  static func height(with title: String?) -> CGFloat {
    guard let title = title else { return 54 }
    return (title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 64, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)],
      context: nil).height + 54
  }
}

class FeedViewController: UIViewController {
  let feed: Feed

  lazy var headerView: FeedHeaderView = {
    let headerView = FeedHeaderView()
    return headerView
  }()

  lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.isDirectionalLockEnabled = true
    return webView
  }()

  init(feed: Feed) {
    self.feed = feed
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }

  private func setUp() {
    view.addSubview(headerView)
    view.addSubview(webView)

    headerView.snp.makeConstraints { make in
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(FeedHeaderView.height(with: feed.title))
    }
    webView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }

    webView.loadHTMLString(feed.content, baseURL: nil)
  }
}
