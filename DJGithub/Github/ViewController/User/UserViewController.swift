//
//  UserViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit
import SnapKit
import Combine

struct ContentAndColorMapping {
  let content: String
  let color: UIColor

  init(content: String) {
    self.content = content
    self.color = content.isEmpty ? .textGrayColor : .textColor
  }
}

enum UserCellType {
  case email
  case location
  case company
  case link

  var isShowAccessory: Bool {
    return [UserCellType.email, UserCellType.link].contains(self)
  }

  var iconImageName: String {
    switch self {
    case .email: return "email"
    case .link: return "link"
    case .company: return "group"
    case .location: return "location"
    }
  }

  func getContent(by user: UserViewer?) -> ContentAndColorMapping {
    guard let user = user else {
      return ContentAndColorMapping(content: "")
    }
    switch self {
    case .email: return ContentAndColorMapping(content: user.email)
    case .location: return ContentAndColorMapping(content: user.location)
    case .company: return ContentAndColorMapping(content: user.company)
    case .link: return ContentAndColorMapping(content: user.websiteUrl)
    }
  }

  func getContent(by organization: Organization?) -> ContentAndColorMapping {
    guard let organization = organization else {
      return ContentAndColorMapping(content: "")
    }
    switch self {
    case .email: return ContentAndColorMapping(content: organization.email)
    case .location: return ContentAndColorMapping(content: organization.location)
    case .company: return ContentAndColorMapping(content: "团队")
    case .link: return ContentAndColorMapping(content: organization.websiteUrl)
    }
  }
}

private enum CellType {
  case userContribution(UserContribution)
  case blank
  case user(UserCellType)
  case pinnedItem(PinnedRepos)

  var height: CGFloat {
    switch self {
    case .blank: return 10
    case .user: return 44
    case .userContribution: return 100
    case .pinnedItem: return 110
    }
  }
}

class UserViewController: UIViewController {

  lazy var followStatusView: UserStatusView = {
    let view = UserStatusView(layoutLay: .normal)
    view.type = .follow(self.name)
    view.isHidden = true
    return view
  }()

  lazy var userHeaderView: UserHeaderView = {
    let view = UserHeaderView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 135))
    return view
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = userHeaderView
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .backgroundColor
    tableView.register(UserCell.classForCoder(), forCellReuseIdentifier: UserCell.className)
    tableView.register(UserContributionCell.classForCoder(), forCellReuseIdentifier: UserContributionCell.className)
    tableView.register(PinnedItemsCell.classForCoder(), forCellReuseIdentifier: PinnedItemsCell.className)
    return tableView
  }()

  let name: String

  private var userViewer: UserViewer?
  private var userViewModel: UserViewModel

  fileprivate var dataSource: [CellType] = []

  init(name: String) {
    self.name = name
    self.userViewModel = UserViewModel()
    super.init(nibName: nil, bundle: nil)
  }

  init(with viewer: UserViewer) {
    self.userViewer = viewer
    self.userViewModel = UserViewModel()
    self.name = viewer.login
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
    self.navigationItem.title = "User"
    view.backgroundColor = .backgroundColor
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.followStatusView)

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }

    self.userViewModel.userObserver.bind { [weak self] userViewer in
      DispatchQueue.main.async {
        self?.loadUserViewerInfo(with: userViewer)
        self?.tableView.reloadData()
      }
    }

    if let userViewer {
      userViewModel.update(userViewer)
    } else {
      Task {
        view.startLoading()
        await userViewModel.fetchUser(with: name)
      }
    }

    userHeaderView.renderHeightClosure = { [weak self] height in
      guard let strongSelf = self else { return }
      strongSelf.userHeaderView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: height)
      strongSelf.tableView.beginUpdates()
      strongSelf.tableView.endUpdates()
    }
    userHeaderView.jumpClosure = { [weak self] in
      guard let strongSelf = self, ConfigManager.checkOwner(by: strongSelf.name) else { return }
      strongSelf.naviVc?.navigationController?.pushToUserInfo()
    }
    userHeaderView.tapCounterClosure = { [weak self] index in
      guard let strongSelf = self, let userViewer = strongSelf.userViewModel.userViewer else { return }
      strongSelf.naviVc?.navigationController?.pushToUserInteract(
        with: userViewer.login,
        title: userViewer.name ?? "",
        selectedIndex: index
      )
    }
  }

  private func loadUserViewerInfo(with userViewer: UserViewer?) {
    view.stopLoading()
    guard let userViewer else { return }

    self.followStatusView.isHidden = userViewer.isViewer
    self.followStatusView.active = userViewer.viewerIsFollowing
    self.navigationItem.title = userViewer.name
    userHeaderView.render(with: userViewer)
    if let userContribution = userViewer.userContribution {
      self.dataSource = [.blank, .userContribution(userContribution)]
    }
    if userViewer.pinnedItems.nodes.count > 0 {
      self.dataSource.append(contentsOf: [.blank, .pinnedItem(userViewer.pinnedItems)])
    }
    self.dataSource.append(contentsOf: [.blank, .user(.company), .user(.location), .user(.email), .user(.link)])
    tableView.reloadData()
  }

  private func handle(with contribution: UserContribution) {
    self.dataSource.insert(.blank, at: 0)
    self.dataSource.insert(.userContribution(contribution), at: 1)
    tableView.reloadData()
  }

}

extension UserViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellType = self.dataSource[indexPath.row]
    switch cellType {
    case .userContribution(let userContribution):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserContributionCell.className, for: indexPath) as! UserContributionCell
      cell.render(with: userContribution)
      return cell
    case .blank:
      let cell = UITableViewCell()
      cell.backgroundColor = .backgroundColor
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
      return cell
    case .user(let userType):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.className, for: indexPath) as! UserCell
      if userType.isShowAccessory {
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.accessoryType = .none
      }
      let contentModel = userType.getContent(by: userViewModel.userViewer)
      cell.render(with: userType.iconImageName, content: contentModel.content, contentColor: contentModel.color)
      return cell
    case .pinnedItem(let pinnedItems):
      let cell = tableView.dequeueReusableCell(withIdentifier: PinnedItemsCell.className, for: indexPath) as! PinnedItemsCell
      cell.render(with: pinnedItems)
      cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
      cell.onTouchPinnedItem = { [weak self] item in
        guard let strongSelf = self else { return }
        strongSelf.naviVc?.navigationController?.pushToRepo(with: strongSelf.name, repoName: item.name)
      }
      return cell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.dataSource[indexPath.row].height
  }
}

extension UserViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let cellType = self.dataSource[indexPath.row]
    if case CellType.user(let userType) = cellType {
      let content = userType.getContent(by: self.userViewer)
      switch userType {
      case .email:
        if let email = userViewModel.userViewer?.email, !email.isEmpty {
          UIPasteboard.general.string = content.content
          HUD.show(with: "已经复制到粘贴板")
        }
      case .link:
        if let link = userViewModel.userViewer?.websiteUrl, !link.isEmpty {
          self.naviVc?.navigationController?.pushToWebView(with: link)
        }
      default:
        break
      }
    }
  }
}
