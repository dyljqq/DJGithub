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
    tableView.showsVerticalScrollIndicator = true
    tableView.register(IssueCell.classForCoder(), forCellReuseIdentifier: IssueCell.className)
    return tableView
  }()
  
  init(with userName: String, repoName: String, issusState: Issue.IssueState) {
    self.userName = userName
    self.repoName = repoName
    self.state = issusState
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
    self.navigationItem.title = "issue"
    
    view.addSubview(self.tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    
    view.startLoading()
    
    tableView.addHeader { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.nextPageState.update(start: 1, hasNext: true, isLoading: false)
      strongSelf.loadNext(start: strongSelf.nextPageState.start)
    }
    tableView.addFooter { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.loadNext(start: strongSelf.nextPageState.start + 1)
    }
    nextPageState.update(start: 1, hasNext: true, isLoading: false)
    self.loadNext(start: self.nextPageState.start)
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
    self.navigationController?.pushToRepoIssue(with: userName, repoName: repoName, issueNum: issue.issue.number)
  }
}

extension RepoIssuesViewController {
  func performLoad(successHandler: @escaping ([IssueLayout], Bool) -> (), failureHandler: @escaping (String) -> ()) {
    Task {
      let issues = await RepoManager.getRepoIssues(
        with: self.userName,
        repoName: self.repoName,
        params: ["state": self.state.rawValue, "page": "\(self.nextPageState.start)"]
      )
      var issueLayouts = [IssueLayout]()
      for issue in issues {
        var layout = IssueLayout(issue: issue)
        layout.calHeight()
        issueLayouts.append(layout)
      }
      successHandler(issueLayouts, issues.count > 0)
    }
  }
}
