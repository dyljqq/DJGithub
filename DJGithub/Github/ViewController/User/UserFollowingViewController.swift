//
//  UserFollowingViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import UIKit

enum UserFollowingType {
  case watches(String)
  case star(String)
  case contributor(String)
  case following(String)
  case followers(String)
  case search(String)
  case unknown
  
  var title: String {
    switch self {
    case .watches: return "Watches"
    case .star: return "Stargazers"
    case .contributor: return "Contributor"
    case .following: return "Following"
    case .followers: return "Followers"
    case .search: return "Users"
    case .unknown: return ""
    }
  }
}

class UserFollowingViewController: UIViewController, NextPageLoadable {

  var nextPageState: NextPageState = NextPageState()
  
  typealias DataType = UserFollowing
  
  var dataSource: [DataType] = []
  
  var firstPageIndex: Int {
    return 1
  }
  
  let pageSize = 30
  var type: UserFollowingType = .unknown
  
  init(with type: UserFollowingType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  init() {
    self.type = .following("")
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
    tableView.register(SimpleUserCell.classForCoder(), forCellReuseIdentifier: SimpleUserCell.className)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  private func setUp() {
    self.navigationItem.title = "Developers"
    self.view.backgroundColor = .backgroundColor
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    
    nextPageState.update(start: firstPageIndex, hasNext: true, isLoading: false)
    view.startLoading()
    
    tableView.addHeader { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.nextPageState.update(start: strongSelf.firstPageIndex, hasNext: true, isLoading: false)
      strongSelf.loadData(start: strongSelf.nextPageState.start)
    }
    tableView.addFooter { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.loadData(start: strongSelf.nextPageState.start + 1)
    }
    loadData(start: nextPageState.start)
  }
  
  func loadData(start: Int) {
    loadNext(start: start) { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.view.stopLoading()
      strongSelf.tableView.dj_endRefresh()
      strongSelf.tableView.reloadData()
    }
  }

}

extension UserFollowingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SimpleUserCell.className, for: indexPath) as! SimpleUserCell
    cell.render(with: dataSource[indexPath.row])
    cell.avatarClosure = { [weak self] in
      guard let strongSelf = self else {
        return
      }
      let user = strongSelf.dataSource[indexPath.row]
      strongSelf.navigationController?.pushToUser(with: user.login)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let user = self.dataSource[indexPath.row]
    self.navigationController?.pushToUser(with: user.login)
  }
}

extension UserFollowingViewController {
  
  func performLoad(successHandler: @escaping ([UserFollowing], Bool) -> (), failureHandler: @escaping (String) -> ()) {
    Task {
      let users: [UserFollowing]
      switch type {
      case .following(let name):
        users = await UserManager.getUserFollowing(with: name, page: nextPageState.start)
      case .star(let repoName):
        users = await UserManager.fetch(by: .stargazers(repoName, ["page": "\(nextPageState.start)"]))
      case .contributor(let repoName):
        users = await UserManager.fetch(by: .contributors(repoName, ["page": "\(nextPageState.start)"]))
      case .watches(let repoName):
        users = await UserManager.fetch(by: .subscribers(repoName, ["page": "\(nextPageState.start)"]))
      case .followers(let name):
        users = await UserManager.getUserFollowers(with: name, page: nextPageState.start)
      case .search(let q):
        if let r = await SearchManager.searchUsers(with: q, page: nextPageState.start){
          users = r.items
        } else {
          users = []
        }
      case .unknown:
        users = []
      }
      successHandler(users, users.count == pageSize)
    }
  }
  
}
