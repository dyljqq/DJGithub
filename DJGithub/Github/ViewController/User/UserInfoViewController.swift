//
//  UserInfoViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/8.
//

import UIKit

enum UserInfoType: String {
  case name, bio, company, location, email, blog
  
  var name: String {
    switch self {
    case .name: return "Name"
    case .bio: return "Bio"
    case .company: return "Company"
    case .email: return "Public Email"
    case .location: return "Location"
    case .blog: return "URL"
    }
  }
  
  func getContent(by user: User?) -> String? {
    guard let user = user else { return nil }
    
    switch self {
    case .name: return user.name
    case .bio: return user.bio
    case .company: return user.company
    case .location: return user.location
    case .email: return user.email
    case .blog: return user.blog
    }
  }
}

class UserInfoViewController: UIViewController {
  
  enum CellType {
    case blank, userInfo(UserInfoType)
    
    var height: CGFloat {
      switch self {
      case .blank: return 20
      case .userInfo: return 44
      }
    }
  }
  
  var user: User?
  
  var dataSource: [CellType] = [
    .blank,
    .userInfo(.name),
    .userInfo(.bio),
    .blank,
    .userInfo(.email),
    .userInfo(.location),
    .userInfo(.company),
    .userInfo(.blog),
  ]
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.className)
    tableView.register(UserInfoCell.classForCoder(), forCellReuseIdentifier: UserInfoCell.className)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Task {
      self.user = await UserManager.getUser(with: ConfigManager.shared.viewerName)
      self.tableView.reloadData()
    }
  }
  
  private func setUp() {
    self.navigationItem.title = ConfigManager.shared.viewerName
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension UserInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellType = self.dataSource[indexPath.row]
    switch cellType {
    case .blank:
      let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
      cell.backgroundColor = .backgroundColor
      cell.selectionStyle = .none
      return cell
    case .userInfo(let userType):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.className, for: indexPath) as! UserInfoCell
      cell.render(with: userType.name, content: userType.getContent(by: user))
      cell.accessoryType = .disclosureIndicator
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let type = self.dataSource[indexPath.row]
    return type.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let type = self.dataSource[indexPath.row]
    switch type {
    case .userInfo(let userType):
      self.navigationController?.pushToUserInfoEdit(with: userType, user: user)
    default:
      break
    }
  }
  
}
