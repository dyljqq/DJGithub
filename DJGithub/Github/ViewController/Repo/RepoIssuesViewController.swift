//
//  RepoIssuesViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

class RepoIssuesViewController: UIViewController, NextPageLoadable {
  typealias DataType = IssueLayout

  let userName: String
  let repoName: String
  let issueState: RepoIssuesStateViewController.IssueState
  let state: Issue.IssueState

  var dataSource: [DataType] = []
  var nextPageState: NextPageState = NextPageState()
  var firstPageIndex: Int {
    return 1
  }

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
    tableView.register(IssueCell.classForCoder(), forCellReuseIdentifier: IssueCell.className)
    return tableView
  }()

  init(with userName: String, repoName: String, issueState: RepoIssuesStateViewController.IssueState = .issue, state: Issue.IssueState = .open) {
    self.userName = userName
    self.repoName = repoName
    self.state = state
    self.issueState = issueState
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUp()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  private func setUp() {
    self.navigationItem.title = "issue"

    view.addSubview(self.tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }

    view.startLoading()

    tableView.addHeader { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.nextPageState.update(start: 1, hasNext: true, isLoading: false)
      strongSelf.loadNext(start: 1)
    }
    tableView.addFooter { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.loadNext(start: strongSelf.nextPageState.start + 1)
    }
    nextPageState.update(start: 1, hasNext: true, isLoading: false)
    self.loadNext(start: 1)
  }

  func refresh() {
    tableView.dj_beginRefresh()
  }

  func loadNext(start: Int) {
    loadNext(start: start) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.view.stopLoading()
      strongSelf.tableView.dj_endRefresh()
      strongSelf.tableView.reloadData()
    }
  }

}

extension RepoIssuesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: IssueCell.className, for: indexPath) as! IssueCell
    let issue = self.dataSource[indexPath.row]
    cell.render(with: issue)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let issueLayout = self.dataSource[indexPath.row]
    return issueLayout.height
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let issue = self.dataSource[indexPath.row]
    switch issueState {
    case .issue:
      self.navigationController?.pushToRepoIssue(with: userName, repoName: repoName, issueNum: issue.issue.number)
    case .pull:
      self.navigationController?.pushToRepoPull(with: userName, repoName: repoName, pullNum: issue.issue.number)
    }
  }
}

extension RepoIssuesViewController {
  func performLoad(successHandler: @escaping ([IssueLayout], Bool) -> Void, failureHandler: @escaping (String) -> Void) {
    Task {
      let issues: [Issue]
      switch self.issueState {
      case .issue:
        issues = await RepoManager.getRepoIssues(
          with: self.userName,
          repoName: self.repoName,
          params: ["state": self.state.rawValue, "page": "\(self.nextPageState.start)"]
        ).filter { $0.pullRequest == nil }
      case .pull:
        issues = await RepoManager.getRepoPullIssues(
          with: userName,
          repoName: repoName,
          params: ["state": self.state.rawValue, "page": "\(self.nextPageState.start)"]
        )
      }
      var issueLayouts = [IssueLayout]()
      for issue in issues {
        var layout = IssueLayout(issue: issue)
        layout.calHeight()
        switch self.issueState {
        case .issue: layout.imageName = issue.state.imageName
        case .pull: layout.imageName = "pull-request"
        }
        issueLayouts.append(layout)
      }
      successHandler(issueLayouts, issues.count > 0)
    }
  }
}

fileprivate extension Issue.IssueState {
  var imageName: String {
    switch self {
    case .open: return "check"
    case .closed: return "close"
    }
  }
}
