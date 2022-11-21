//
//  UserContainerViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/11.
//

import UIKit

class UserContainerViewController: UIViewController {

  let name: String
  var type: UserContainerType?

  lazy var followStatusView: UserStatusView = {
    let view = UserStatusView(layoutLay: .normal)
    view.type = .follow(self.name)
    view.isHidden = true
    return view
  }()

  init(name: String) {
    self.name = name
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
    view.backgroundColor = .backgroundColor

    if let type = type {
      switch type {
      case .user: addUserViewController(with: name)
      case .organization: addOrganizationViewController(with: name)
      }
    } else {
      Task {
        view.startLoading()
        if let viewer = await UserManager.fetchUserInfo(by: name) {
          addUserViewController(with: name, viewer: viewer)
        } else if let organization = await UserManager.fetchOrganizationInfo(by: name) {
          addOrganizationViewController(with: name, organization: organization)
        }
        view.stopLoading()
      }
    }
  }

  private func addUserViewController(with name: String, viewer: UserViewer? = nil) {
    self.navigationItem.title = "User"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.followStatusView)

    let vc: UserViewController
    if let viewer = viewer {
      vc = UserViewController(with: viewer)
    } else {
      vc = UserViewController(name: name)
    }
    setUp(with: vc)

    if let viewer = viewer {
      self.followStatusView.isHidden = viewer.isViewer
      self.followStatusView.active = viewer.viewerIsFollowing
    }
  }

  private func addOrganizationViewController(with name: String, organization: Organization? = nil) {
    self.navigationItem.title = "Organization"

    let vc = OrganizationViewController(with: name)
    vc.organization = organization
    setUp(with: vc)
  }

  private func setUp(with vc: UIViewController) {
    self.addChild(vc)
    self.view.addSubview(vc.view)
    vc.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

}

extension UserContainerViewController {
  enum UserContainerType {
    case user
    case organization
  }
}
