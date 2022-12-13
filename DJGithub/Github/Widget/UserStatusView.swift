//
//  UserStatusView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import UIKit

enum UserStatusViewType {
  case follow(String)
  case star(String)
  case unknown

  func getActiveContent(isActive: Bool) -> String {
    switch self {
    case .follow: return isActive.followText
    case .star: return isActive.starText
    case .unknown: return ""
    }
  }
}

class UserStatusView: UIView {

  enum UserStatusType {
    case active
    case inactive
    case loading
  }

  enum LayoutWay {
    case normal
    case auto
  }

  let layoutWay: LayoutWay
  var type: UserStatusViewType = .unknown

  var height: CGFloat = 30

  var touchClosure: (() -> Void)?

  var contentLabel: UILabel = {
    let label = UILabel()
    return label
  }()

  var activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    return activityIndicatorView
  }()

  init(layoutLay: LayoutWay = .auto) {
    layoutWay = layoutLay
    super.init(frame: .zero)
    setUp()
  }

  func render(with statusType: UserStatusType, content: String = "", widthClosure: ((CGFloat) -> Void)? = nil) {
    if case .loading = statusType {
      activityIndicatorView.isHidden = false
      activityIndicatorView.startAnimating()
      contentLabel.isHidden = true
      return
    }

    activityIndicatorView.stopAnimating()
    activityIndicatorView.isHidden = true
    contentLabel.isHidden = false
    contentLabel.text = content

    let font: UIFont?
    var fontSize: CGFloat = 14
    switch statusType {
    case .active:
      font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
      contentLabel.textColor = .white
      backgroundColor = .lightBlue
    case .inactive:
      fontSize = 12
      font = UIFont.systemFont(ofSize: fontSize)
      contentLabel.textColor = .blue
      backgroundColor = .backgroundColor
    default:
      font = nil
    }

    if let font = font {
      contentLabel.font = font
      DispatchQueue.global().async {
        let width = (content as NSString).boundingRect(with: CGSize(width: 0, height: 14), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size.width
        DispatchQueue.main.async {
          if case .normal = self.layoutWay {
            self.frame = CGRect(x: 0, y: 0, width: width + 30, height: self.height)
            self.activityIndicatorView.center = self.center
            self.contentLabel.frame = CGRect(x: 15, y: (self.height - fontSize) / 2, width: width, height: fontSize)
          } else {
            self.snp.updateConstraints { make in
              make.width.equalTo(width + 30)
            }
          }
        }
      }
    }
  }

  private func setUp() {
    addSubview(contentLabel)
    addSubview(activityIndicatorView)

    let tap = UITapGestureRecognizer(target: self, action: #selector(touchAction))
    addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true

    self.layer.cornerRadius = height / 2

    updateLayout()
  }

  func updateLayout() {
    switch layoutWay {
    case .auto:
      contentLabel.snp.makeConstraints { make in
        make.center.equalTo(self)
      }
      activityIndicatorView.snp.makeConstraints { make in
        make.center.equalTo(self)
      }
    case .normal:
      self.frame = CGRect(x: 0, y: 0, width: 0, height: height)
    }
  }

  @objc func touchAction() {
    activeAction()
    touchClosure?()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

private var activeKey: UInt8 = 0
extension UserStatusView {
  var active: Bool {
    get {
      return objc_getAssociatedObject(self, &activeKey) as? Bool ?? false
    }

    set {
      self.render(with: newValue ? .active : .inactive, content: self.type.getActiveContent(isActive: newValue))
      objc_setAssociatedObject(self, &activeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }

  func activeAction() {
    self.render(with: .loading)
    Task {
      let statusModel: StatusModel?
      switch self.type {
      case .follow(let name):
        if active {
          statusModel = await UserManager.unFollowUser(with: name)
        } else {
          statusModel = await UserManager.followUser(with: name)
        }
      case .star(let name):
        if active {
          statusModel = await RepoManager.unStarRepo(with: name)
        } else {
          statusModel = await RepoManager.starRepo(with: name)
        }
      case .unknown:
        statusModel = nil
      }

      if let statusModel = statusModel, statusModel.isStatus204 {
        active = !active
      }
    }
  }
}

class FollowUserStatusView: UserStatusView {

  override init(layoutLay: UserStatusView.LayoutWay = .auto) {
    super.init(layoutLay: layoutLay)

    self.isHidden = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func render(with userName: String) {
    self.type = .follow(userName)
    Task {
      var status = await UserFollowingManager.shared.followingStatus(with: userName)
      if case UserFollowingStatus.unknown = status {
        status = await UserFollowingManager.shared.update(with: userName)
      }
      switch status {
      case .unfollow:
        self.isHidden = false
        self.active = false
      case .following:
        self.isHidden = false
        self.active = true
      case .unknown:
        self.isHidden = true
      }
    }
  }

}
