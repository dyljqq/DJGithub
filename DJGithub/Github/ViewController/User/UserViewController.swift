//
//  UserViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit
import SnapKit
import Combine

fileprivate enum UserType {
  case email
  case location
  case company
  case link
  
  var isShowAccessory: Bool {
    return [UserType.email, UserType.link].contains(self)
  }
  
  var iconImageName: String {
    switch self {
    case .email: return "email"
    case .link: return "link"
    case .company: return "group"
    case .location: return "location"
    }
  }
  
  func getContent(by user: UserViewer?) -> (String, UIColor) {
    guard let user = user else {
      return ("", .white)
    }
    switch self {
    case .email: return convertContent(user.email, placeHolder: "邮箱")
    case .location: return convertContent(user.location, placeHolder: "地点")
    case .company: return convertContent(user.company, placeHolder: "团队")
    case .link: return convertContent(user.websiteUrl, placeHolder: "个人主页")
    }
  }
  
  func convertContent(_ content: String?, placeHolder: String) -> (String, UIColor) {
    guard let content = content else {
      return (placeHolder, UIColor.textGrayColor)
    }
    return !content.isEmpty ? (content, UIColor.textColor) : (placeHolder, UIColor.textGrayColor)
  }
}

fileprivate enum CellType {
  case userContribution(UserContribution)
  case blank
  case user(UserType)
  
  var height: CGFloat {
    switch self {
    case .blank: return 10
    case .user: return 44
    case .userContribution: return 100
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
    return tableView
  }()
    
  let name: String
  
  var user: User?
  var userViewer: UserViewer?
  
  fileprivate var dataSource: [CellType] = []
  
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
    self.navigationItem.title = "User"
    view.backgroundColor = .backgroundColor
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.followStatusView)
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    self.view.startLoading()
    
    Task {
      if let userViewer = await UserManager.fetchUserInfo(by: self.name) {
        self.userViewer = userViewer
        self.loadUserViewerInfo(with: userViewer)
      }
    }
    
    userHeaderView.renderHeightClosure = { [weak self] height in
      guard let strongSelf = self else { return }
      strongSelf.userHeaderView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: height)
      strongSelf.tableView.beginUpdates()
      strongSelf.tableView.endUpdates()
    }
    userHeaderView.jumpClosure = { [weak self] in
      self?.navigationController?.pushToUserInfo()
    }
  }
  
  private func loadUserViewerInfo(with userViewer: UserViewer) {
    view.stopLoading()
    
    self.followStatusView.isHidden = userViewer.isViewer
    self.followStatusView.active = userViewer.viewerIsFollowing
    self.navigationItem.title = userViewer.name
    userHeaderView.render(with: userViewer)
    if let userContribution = userViewer.userContribution {
      self.dataSource = [.blank, .userContribution(userContribution)]
    }
    self.dataSource.append(contentsOf: [.blank, .user(.company), .user(.location), .user(.email), .user(.link)])
    tableView.reloadData()
    
    userHeaderView.tapCounterClosure = { [weak self] index in
      guard let strongSelf = self else { return }
      strongSelf.navigationController?.pushToUserInteract(
        with: strongSelf.userViewer?.login ?? "",
        title: strongSelf.userViewer?.name ?? "",
        selectedIndex: index
      )
    }
  }
  
  private func handle(with contribution: UserContribution) {
    self.dataSource.insert(.blank, at: 0)
    self.dataSource.insert(.userContribution(contribution), at: 1)
    tableView.reloadData()
  }
  
  private func configNavigationRightButton() {
    Task {
      if let status = await UserManager.checkFollowStatus(with: self.name) {
        self.followStatusView.active = status.isStatus204
      }
    }
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
      return cell
    case .user(let userType):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.className, for: indexPath) as! UserCell
      if userType.isShowAccessory {
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.accessoryType = .none
      }
      let (content, color) = userType.getContent(by: userViewer)
      cell.render(with: userType.iconImageName, content: content, contentColor: color)
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
      let (content, _) = userType.getContent(by: self.userViewer)
      switch userType {
      case .email:
        if let email = user?.email, !email.isEmpty {
          UIPasteboard.general.string = content
          HUD.show(with: "已经复制到粘贴板")
        }
      case .link:
        if let link = user?.blog, !link.isEmpty {
          self.navigationController?.pushToWebView(with: link)
        }
      default:
        break
      }
    }
  }
}
