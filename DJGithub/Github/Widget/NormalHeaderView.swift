//
//  NormalHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

class NormalHeaderView: UIView {

  static let defaultFrame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 135)

  class CounterView: UIView {

    lazy var counterLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.font = UIFont.systemFont(ofSize: 16)
      return label
    }()

    lazy var nameLabel: UILabel = {
      let label = UILabel()
      label.textColor = UIColorFromRGB(0x666666)
      label.font = UIFont.systemFont(ofSize: 12)
      return label
    }()

    var tapClosure: (() -> Void)?

    init() {
      super.init(frame: CGRect.zero)

      setUp()
    }

    func setUp() {
      addSubview(counterLabel)
      addSubview(nameLabel)

      counterLabel.snp.makeConstraints { make in
        make.centerX.equalTo(self)
        make.bottom.equalTo(self.snp.centerY)
      }
      nameLabel.snp.makeConstraints { make in
        make.centerX.equalTo(self)
        make.top.equalTo(self.snp.centerY)
      }

      self.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
      self.addGestureRecognizer(tap)
    }

    @objc func tapAction() {
      tapClosure?()
    }

    func render(with count: Int, name: String) {
      self.counterLabel.text = count.toGitNum
      self.nameLabel.text = name
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

  }

  lazy var avatarImageView: AvatarImageView = {
    let imageView = AvatarImageView()
    imageView.layer.cornerRadius = 8
    imageView.layer.masksToBounds = true
    return imageView
  }()

  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightBlue
    label.font = UIFont.boldSystemFont(ofSize: 16)
    return label
  }()

  lazy var loginLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x222222)
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()

  lazy var bioLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x444444)
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 0
    return label
  }()

  lazy var joinedLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColorFromRGB(0x444444)
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()

  lazy var arrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "arrow-24")
    imageView.contentMode = .scaleAspectFit
    imageView.isHidden = true
    return imageView
  }()

  lazy var horizontalLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColorFromRGB(0xf5f5f5)
    return view
  }()

  lazy var repoView: CounterView = {
    return CounterView()
  }()

  lazy var followersView: CounterView = {
    return CounterView()
  }()

  lazy var followingView: CounterView = {
    return CounterView()
  }()

  var jumpClosure: (() -> Void)?
  var tapCounterClosure: ((Int) -> Void)?
  var renderHeightClosure: ((CGFloat) -> Void)?
  var heightToken: NSKeyValueObservation?

  init() {
    super.init(frame: NormalHeaderView.defaultFrame)

    setUp()
  }

  private func setUp() {
    self.backgroundColor = .white

    addSubview(avatarImageView)
    addSubview(nameLabel)
    addSubview(loginLabel)
    addSubview(bioLabel)
    addSubview(joinedLabel)
    addSubview(arrowImageView)

    addSubview(horizontalLine)
    addSubview(repoView)
    addSubview(followersView)
    addSubview(followingView)

    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(12)
      make.width.equalTo(60)
      make.height.equalTo(60)
    }
    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.top.equalTo(avatarImageView)
    }
    loginLabel.snp.makeConstraints { make in
      make.centerY.equalTo(nameLabel)
      make.leading.equalTo(nameLabel.snp.trailing)
      make.trailing.equalTo(bioLabel)
    }
    bioLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(5)
      make.leading.equalTo(nameLabel)
      make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
      make.height.equalTo(20)
    }
    arrowImageView.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.height.equalTo(24)
      make.width.equalTo(12)
      make.centerY.equalTo(bioLabel)
    }
    joinedLabel.snp.makeConstraints { make in
      make.top.equalTo(bioLabel.snp.bottom).offset(5)
      make.trailing.equalTo(loginLabel)
      make.leading.equalTo(bioLabel)
    }
    horizontalLine.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerX.equalTo(self)
      make.height.equalTo(0.5)
      make.top.equalTo(joinedLabel.snp.bottom).offset(12)
    }
    repoView.snp.makeConstraints { make in
      make.width.equalTo(self).dividedBy(3)
      make.height.equalTo(44)
      make.leading.equalTo(self)
      make.top.equalTo(horizontalLine.snp.bottom).offset(5)
    }
    followersView.snp.makeConstraints { make in
      make.width.height.top.equalTo(repoView)
      make.leading.equalTo(repoView.snp.trailing)
    }
    followingView.snp.makeConstraints { make in
      make.width.height.top.equalTo(repoView)
      make.leading.equalTo(followersView.snp.trailing)
    }

    self.isUserInteractionEnabled = true
    repoView.tapClosure = { [weak self] in
      self?.tapCounterClosure?(0)
    }
    followersView.tapClosure = { [weak self] in
      self?.tapCounterClosure?(1)
    }
    followingView.tapClosure = { [weak self] in
      self?.tapCounterClosure?(2)
    }

    heightToken = self.bioLabel.observe(\.text) { [weak self] label, _ in
      guard let strongSelf = self, let text = label.text else { return }
      DispatchQueue.global().async {
        let rect = (text as NSString).boundingRect(
          with: CGSize(width: FrameGuide.screenWidth - 108, height: 0),
          options: .usesLineFragmentOrigin,
          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
          context: nil)
        DispatchQueue.main.async {
          strongSelf.bioLabel.snp.updateConstraints { make in
            make.height.equalTo(rect.height)
          }
          strongSelf.renderHeightClosure?(rect.height + 120)
        }
      }
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(jumpAction))
    addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  @objc func jumpAction() {
    self.jumpClosure?()
  }

  deinit {
    self.heightToken?.invalidate()
  }

}
