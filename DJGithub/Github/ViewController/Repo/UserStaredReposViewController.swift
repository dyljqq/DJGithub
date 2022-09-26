//
//  UserStaredReposViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserStaredReposViewController: UIViewController {

  let userName: String

  var viewModel = RepoViewModel()
  
  lazy var tableView: UITableView = {
    let tableView: UITableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
//    tableView.contentInsetAdjustmentBehavior = .never
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
    
    self.navigationItem.title = "Stars"
    setUp()
  }
  
  func setUp() {
    view.backgroundColor = .backgroundColor
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
//      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.top.bottom.leading.trailing.equalTo(self.view)
    }
    
    view.startLoading()

    tableView.addHeader { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.fetchRepos()
    }
    fetchRepos()
  }
  
  func fetchRepos() {
    Task {
      if let repos = await RepoViewModel.fetchStaredRepos(with: userName, page: RepoViewModel.pageStart) {
        view.stopLoading()
        await handleData(repos: repos.items, page: RepoViewModel.pageStart)
        
        if !repos.items.isEmpty {
          tableView.addFooter { [weak self] in
            guard let strongSelf = self else {
              return
            }
            Task {
              if let repos = await RepoViewModel.fetchStaredRepos(with: strongSelf.userName, page: strongSelf.viewModel.page) {
                await strongSelf.handleData(repos: repos.items, page: strongSelf.viewModel.page + 1)
              } else {
                strongSelf.tableView.dj_endRefresh()
              }
            }
          }
        }
      } else {
        view.stopLoading()
        tableView.dj_endRefresh()
      }
    }
  }
  
  func handleData(repos: [Repo], page: Int) async {
    let languages = repos.map { Language(id: 0, language: $0.language ?? "Unknown", hex: UIColor.randomHex) }
    await LanguageManager.save(languages)

    tableView.dj_endRefresh()
    viewModel.update(by: page, repos: repos, isEnded: repos.isEmpty)
    tableView.reloadData()
  }

}

extension UserStaredReposViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.repos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UserStaredRepoCell.className, for: indexPath) as! UserStaredRepoCell
    cell.render(with: viewModel.repos[indexPath.row])
    cell.avatarImageViewTappedClosure = { [weak self] userName in
      guard let strongSelf = self else {
        return
      }
      strongSelf.navigationController?.pushToUser(with: userName)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UserStaredRepoCell.cellHeight(by: viewModel.repos[indexPath.row])
  }
}

extension UserStaredReposViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let repo = viewModel.repos[indexPath.row]
    self.navigationController?.pushToRepo(with: repo.fullName)
  }
}
