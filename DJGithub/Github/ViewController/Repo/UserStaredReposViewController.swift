//
//  UserStaredReposViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit
import DJRefresh

enum UserRepoState {
  case fork(String)
  case star(String)
  case repos(String)
  case subscription(String)
  case search(String)
  case unknown
}

class UserStaredReposViewController: UIViewController, NextPageLoadable {
  typealias DataType = Repo
  var firstPageIndex: Int {
    return 1
  }

  var dataSource: [Repo] = []
  var nextPageState: NextPageState = NextPageState()
  var userRepoState: UserRepoState
  var repo: Repo?
  var isViewer: Bool = false

  lazy var tableView: UITableView = {
    let tableView: UITableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
    tableView.register(UserStaredRepoCell.classForCoder(), forCellReuseIdentifier: UserStaredRepoCell.className)
    return tableView
  }()

  init(userRepoState: UserRepoState) {
    self.userRepoState = userRepoState
    super.init(nibName: nil, bundle: nil)
  }

  init(with state: UserRepoState, repo: Repo? = nil) {
    self.userRepoState = state
    self.repo = repo
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    self.userRepoState = .unknown
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
      make.top.bottom.leading.trailing.equalTo(self.view)
    }
    // github的首页数据为1
    nextPageState.update(start: firstPageIndex, hasNext: true, isLoading: false)

    loadCacheData()

    tableView.addHeader { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.nextPageState.update(start: strongSelf.firstPageIndex, hasNext: true, isLoading: false)
      strongSelf.loadNext(start: strongSelf.nextPageState.start)
    }

    tableView.addFooter { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.loadNext(start: strongSelf.nextPageState.start + 1)
    }
    loadNext(start: nextPageState.start)
  }

  func loadNext(start: Int) {
    loadNext(start: start) { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.view.stopLoading()
      strongSelf.tableView.dj_endRefresh()
      strongSelf.tableView.reloadData()
    }
  }

  private func loadCacheData() {
    switch userRepoState {
    case .star:
      if let repos = DJUserDefaults.getStaredRepos() {
        dataSource = repos
        tableView.reloadData()
      }
    default:
      view.startLoading()
      return
    }
  }

}

extension UserStaredReposViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UserStaredRepoCell.className, for: indexPath) as! UserStaredRepoCell
    var r = dataSource[indexPath.row]
    if case UserRepoState.fork = self.userRepoState,
       let repo = self.repo,
       r.language == nil {
      r.language = repo.language
    }
    cell.render(with: r)
    cell.avatarImageViewTappedClosure = { [weak self] userName in
      guard let strongSelf = self else {
        return
      }
      strongSelf.navigationController?.pushToUser(with: userName)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UserStaredRepoCell.cellHeight(by: dataSource[indexPath.row])
  }
}

extension UserStaredReposViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let repo = dataSource[indexPath.row]
    if let userName = repo.owner?.login {
      self.navigationController?.pushToRepo(with: userName, repoName: repo.name)
    }
  }
}

extension UserStaredReposViewController {

  func performLoad(successHandler: @escaping ([Repo], Bool) -> Void, failureHandler: @escaping (String) -> Void) {
    Task {
      let repos: [Repo]
      switch self.userRepoState {
      case .star(var userName):
        if isViewer && userName.isEmpty {
          userName = LocalUserManager.getViewerName()
        }
        repos = await RepoManager.fetchStaredRepos(with: userName, page: nextPageState.start)
        if nextPageState.start == 1 {
          DJUserDefaults.saveStaredRepos(repos)
        }
      case .fork(let content):
        repos = await RepoManager.fetchForkRepos(with: content, page: nextPageState.start)
      case .repos(let content):
        repos = await RepoManager.fetchUserRepos(with: content, page: nextPageState.start)
      case .subscription(let userName):
        repos = await UserManager.getUserSubscription(with: userName, page: nextPageState.start)
      case .search(let query):
        repos = await SearchManager.searchRepos(with: query, page: nextPageState.start)?.items ?? []
      default:
        repos = []
      }
      let languages = repos.map { Language(id: 0, language: $0.language ?? "Unknown", hex: UIColor.randomHex) }
      await LanguageManager.save(languages)
      successHandler(repos, repos.count > 0)
    }
  }

}
