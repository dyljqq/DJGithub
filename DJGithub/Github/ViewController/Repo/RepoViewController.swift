//
//  RepoViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit
import SafariServices

class RepoViewController: UIViewController {
  
  enum CellType {
    case blank, cell(String, String, String)
    
    var height: CGFloat {
      switch self {
      case .cell: return 44
      case .blank: return 12
      }
    }
  }

  let repoName: String
  var repo: Repo?
  var dataSouce: [CellType] = []
  
  lazy var userStatusView: UserStatusView = {
    let view = UserStatusView(layoutLay: .normal)
    view.type = .star(repoName)
    return view
  }()
  
  lazy var headerView: RepoHeaderView = {
    let headerView = RepoHeaderView()
    return headerView
  }()
  
  lazy var footerView: RepoFooterView = {
    let footerView = RepoFooterView()
    footerView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 0)
    footerView.backgroundColor = UIColor.white
    return footerView
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerView
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.register(RepoCell.classForCoder(), forCellReuseIdentifier: RepoCell.className)
    return tableView
  }()
  
  init(repoName: String) {
    self.repoName = repoName
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
    self.navigationItem.title = "Repository"
    view.backgroundColor = .backgroundColor
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }

    view.startLoading()
    
    Task {
      await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
          await self.fetchRepo()
        }
        group.addTask {
          await self.configStarButton()
        }
        group.addTask {
          Task {
            if let readme = await RepoManager.fetchREADME(with: self.repoName) {
              await self.footerView.render(with: readme.content)
            }
          }
        }
      }
    }
    
    tableView.addHeader { [weak self] in
      self?.fetchRepo()
    }
    
    footerView.fetchHeightClosure = { [weak self] height in
      guard let strongSelf = self else {
        return
      }
      strongSelf.footerView.frame.size.height = height
      strongSelf.tableView.beginUpdates()
      strongSelf.tableView.endUpdates()
    }
    footerView.touchLink = { [weak self] req in
      if let req = req, let url = req.url {
        let vc = SFSafariViewController(url: url)
        self?.navigationController?.present(vc, animated: true)
      }
    }
    
    headerView.tapCounterClosure = { [weak self] index in
      guard let strongSelf = self else { return }
      let types: [RepoInteractViewController.RepoInteractType] = [
        .watches(strongSelf.repoName),
        .star(strongSelf.repoName),
        .forks(strongSelf.repoName)
      ]
      strongSelf.navigationController?.pushToRepoInteract(type: types[index], repo: strongSelf.repo)
    }
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userStatusView)
  }
  
  private func fetchRepo() {
    Task {
      if let repo = await RepoManager.fetchRepo(with: repoName) {
        self.repo = repo
        view.stopLoading()
        self.headerView.render(with: repo)
        dataSouce = [
          .blank,
          .cell("coding", repo.language ?? "unknown", "\(repo.license?.key ?? "") \(NSString(format: "%.2f", Double(repo.size) / 1000))MB"),
          .cell("issue", "Issues", "\(repo.openIssuesCount)"),
          .cell("pull-request", "Pull Requests", ""),
          .blank,
          .cell("git-branch", "Branches", repo.defaultBranch ?? ""),
          .cell("book", "README", "")
        ]
        tableView.reloadData()
      }
      tableView.dj_endRefresh()
    }
  }
  
  func configStarButton() {
    Task {
      if let repoStarStatus = await RepoManager.userStaredRepo(with: repoName) {
        userStatusView.active = repoStarStatus.isStatus204
      }

      userStatusView.touchClosure = { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.userStatusView.activeAction()
      }
    }
  }

}

extension RepoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSouce.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = dataSouce[indexPath.row]
    switch data {
    case .blank:
      let cell = UITableViewCell()
      cell.backgroundColor = .backgroundColor
      return cell
    case .cell(let iconName, let name, let desc):
      let cell = tableView.dequeueReusableCell(withIdentifier: RepoCell.className, for: indexPath) as! RepoCell
      cell.render(with: iconName, name: name, desc: desc)
      cell.accessoryType = .disclosureIndicator
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSouce[indexPath.row].height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}

extension RepoViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > NormalHeaderView.defaultFrame.size.height {
      self.navigationItem.title = self.repoName
    } else {
      self.navigationItem.title = "Repository"
    }
  }
}
