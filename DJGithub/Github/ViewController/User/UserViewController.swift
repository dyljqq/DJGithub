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
  
  func getContent(by user: User?) -> (String, UIColor) {
    guard let user = user else {
      return ("", .white)
    }
    switch self {
    case .email: return convertContent(user.email, placeHolder: "邮箱")
    case .location: return convertContent(user.location, placeHolder: "地点")
    case .company: return convertContent(user.company, placeHolder: "团队")
    case .link: return convertContent(user.blog, placeHolder: "个人主页")
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
  
  var subscriptions: [AnyCancellable] = []
  var userSubject = PassthroughSubject<User, Never>()
  var userContributionSubject = PassthroughSubject<UserContribution, Never>()
  
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
    
    Task {
      await UserManager.getUserFollowing()
    }
  }
  
  func setUp() {
    self.navigationItem.title = "User"
    view.backgroundColor = UIColorFromRGB(0xf5f5f5)
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    self.view.startLoading()
    
    userSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] user in
        self?.handle(with: user)
      })
      .store(in: &subscriptions)
    
    userContributionSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] userContribution in
        self?.handle(with: userContribution)
      })
      .store(in: &subscriptions)
    
    Task {
      await withThrowingTaskGroup(of: Void.self) { [weak self] group in
        guard let strongSelf = self else {
          return
        }
        group.addTask {
          if let user = await UserViewModel.getUser(with: strongSelf.name) {
            await strongSelf.userSubject.send(user)
          }
        }
        group.addTask {
          if let userContribution = await UserViewModel.fetchUserContributions(with: strongSelf.name) {
            await strongSelf.userContributionSubject.send(userContribution)
          }
        }
      }
      self.view.stopLoading()
    }
  }
  
  private func handle(with user: User) {
    self.user = user
    
    self.navigationItem.title = user.name
    userHeaderView.render(with: user)
    self.dataSource = [.blank, .user(.company), .user(.location), .user(.email), .user(.link)]
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
      return cell
    case .user(let userType):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.className, for: indexPath) as! UserCell
      if userType.isShowAccessory {
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.accessoryType = .none
      }
      let (content, color) = userType.getContent(by: user)
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
  }
}
