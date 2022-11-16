//
//  WebViewFooterView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/5.
//

import UIKit

class WebViewFooterView: UIView {
  enum OperationType {
    case back, forward, reload

    var imageName: String {
      switch self {
      case .back: return "arrow"
      case .forward: return "arrow"
      case .reload: return "reload"
      }
    }
  }

  var oprationClosure: ((OperationType) -> Void)?

  var types: [OperationType] = [.back, .forward, .reload]

  lazy var backImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "arrow-24")
    imageView.transform = CGAffineTransformMakeRotation(.pi)

    let tap = UITapGestureRecognizer(target: self, action: #selector(backAction))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true

    return imageView
  }()

  lazy var forwardImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "arrow-24")

    let tap = UITapGestureRecognizer(target: self, action: #selector(forwardAction))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    imageView.contentMode = .scaleToFill

    return imageView
  }()

  lazy var reloadImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "reload")

    let tap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true

    return imageView
  }()

  init() {
    super.init(frame: .zero)
    setUp()
  }

  private func setUp() {
    backgroundColor = .white

    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    addSubview(blurView)
    blurView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }

    addSubview(reloadImageView)
    addSubview(backImageView)
    addSubview(forwardImageView)

    backImageView.snp.makeConstraints { make in
      make.centerX.equalTo(self).multipliedBy(0.25)
      make.top.equalTo(reloadImageView)
      make.width.height.equalTo(24)
    }
    forwardImageView.snp.makeConstraints { make in
      make.centerX.equalTo(self).multipliedBy(0.75)
      make.top.equalTo(reloadImageView)
      make.width.height.equalTo(24)
    }
    reloadImageView.snp.makeConstraints { make in
      make.centerX.equalTo(self).multipliedBy(1.75)
      make.top.equalTo(12)
      make.width.height.equalTo(24)
    }
  }

  @objc func reloadAction() {
    self.oprationClosure?(.reload)
  }

  @objc func backAction() {
    self.oprationClosure?(.back)
  }

  @objc func forwardAction() {
    self.oprationClosure?(.forward)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
