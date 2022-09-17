//
//  UserStaredReposViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserStaredReposViewController: UIViewController {

  let userName: String
  
  var repos: [Repo] = []
  
  lazy var tableView: UITableView = {
    let tableView: UITableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false    
    tableView.register(UserStaredRepoCell.classForCoder(), forCellReuseIdentifier: UserStaredRepoCell.className)
    return tableView
  }()
  
  init(userName: String) {
    self.userName = userName
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    self.userName = ""
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Stars"
    setUp()
  }
  
  func setUp() {
    view.backgroundColor = .backgroundColor
    view.startLoading()

    Task {
      if let repos = await RepoViewModel.fetchStaredRepos(with: self.userName) {
        let languages = repos.items.map { Language(id: 0, language: $0.language ?? "Unknown", hex: UIColor.randomHex) }
        await LanguageManager.save(languages)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
          make.edges.equalTo(view)
        }
        
        tableView.addHeader { [weak self] in
          self?.tableView.dj_endRefresh()
        }
        self.repos = repos.items
        self.tableView.reloadData()
      }
      view.stopLoading()
    }
  }

}

extension UserStaredReposViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UserStaredRepoCell.className, for: indexPath) as! UserStaredRepoCell
    cell.render(with: repos[indexPath.row])
    cell.avatarImageViewTappedClosure = { [weak self] userName in
      guard let strongSelf = self else {
        return
      }
      strongSelf.navigationController?.pushToUser(with: userName)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UserStaredRepoCell.cellHeight(by: repos[indexPath.row])
  }
}

extension UserStaredReposViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
