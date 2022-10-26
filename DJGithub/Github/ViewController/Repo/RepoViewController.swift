//
//  RepoViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit
import SafariServices

enum RepoCellType {
  case blank, language(String, String), issues(String), pull(String), branch(String), readme, primaryLanguage
}

class RepoViewController: UIViewController {

  let userName: String
  let repoName: String
  
  var repo: Repository?
  var dataSouce: [RepoCellType] = []
  
  lazy var userStatusView: UserStatusView = {
    let view = UserStatusView(layoutLay: .normal)
    view.type = .star("\(userName)/\(repoName)")
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
    tableView.register(PrimaryLanguageCell.classForCoder(), forCellReuseIdentifier: PrimaryLanguageCell.className)
    return tableView
  }()
  
  init(with userName: String, repoName: String) {
    self.repoName = repoName
    self.userName = userName
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
          await self.fetchReadme()
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
      guard let strongSelf = self else { return }
      if let req = req,
         let url = req.url {
        
        // github readme中会存在这种链接，比如docs/issue-227.md，那么这种链接会跳转到对应的repo中去。
        var u = url
        if url.isFileURL {
          if let path = url.absoluteString.components(separatedBy: "MarkdownView_MarkdownView.bundle/").last,
             let url = URL(string: "https://github.com/\(strongSelf.userName)/\(strongSelf.repoName)/blob/master/\(path)") {
            u = url
          }
        }
        let vc = SFSafariViewController(url: u)
        self?.navigationController?.present(vc, animated: true)
      }
    }
    
    headerView.tapCounterClosure = { [weak self] index in
      guard let strongSelf = self else { return }
      if let repo = strongSelf.repo {
        strongSelf.navigationController?.pushToRepoInteract(with: repo.nameWithOwner, selectedIndex: index)
      }
    }
    
    headerView.renderHeightClosure = { [weak self] height in
      guard let strongSelf = self else { return }
      strongSelf.headerView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: height)
      strongSelf.tableView.beginUpdates()
      strongSelf.tableView.endUpdates()
    }
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userStatusView)
  }
  
  private func fetchRepo() {
    Task {
      if let repo = await RepoManager.fetchRepository(with: userName, repoName: repoName) {
        userStatusView.active = repo.viewerHasStarred
        self.repo = repo
        if let userName = repo.owner?.login {
          self.userStatusView.isHidden = ConfigManager.checkOwner(by: userName)
        }
        view.stopLoading()
        self.headerView.render(with: repo)

        var languageDes = "\(NSString(format: "%.2f", Double(repo.diskUsage) / 1000))MB"
        if let license = repo.licenseInfo?.spdxId {
          languageDes = "\(license) - " + languageDes
        }
        
        dataSouce = [.blank]
        if let _ = repo.primaryLanguage {
          dataSouce.append(.primaryLanguage)
        }
        dataSouce.append(contentsOf: [
          .language(repo.primaryLanguage?.name ?? "Unknown", languageDes),
          .issues(repo.issues.totalCount.toGitNum),
          .pull(repo.pullRequests.totalCount.toGitNum),
          .blank,
          .branch(repo.defaultBranchRef?.name ?? ""),
          .readme
        ])
        tableView.reloadData()

        updateRepoLanguage(repo: repo)
      }
      view.stopLoading()
      tableView.dj_endRefresh()
    }
  }
  
  func fetchReadme() async {
    if let readme = await RepoManager.fetchREADME(with: "\(userName)/\(repoName)") {
      self.footerView.render(with: readme.content)
    }
  }
  
  private func updateRepoLanguage(repo: Repository) {
    Task {
      if let primaryLanguage = repo.primaryLanguage {
        await LanguageManager.save(with: primaryLanguage.name, color: primaryLanguage.color)
      }
      
      for edge in (repo.languages?.edges ?? []) {
        if let node = edge.node, let name = node.name, let color = node.color {
          await LanguageManager.save(with: name, color: color)
        }
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
      cell.selectionStyle = .none
      cell.backgroundColor = .backgroundColor
      return cell
    case .primaryLanguage:
      let cell = tableView.dequeueReusableCell(withIdentifier: PrimaryLanguageCell.className, for: indexPath) as! PrimaryLanguageCell
      if let repo = repo, let primaryLanguage = repo.primaryLanguage, let languages = repo.languages {
        cell.render(with: primaryLanguage, language: languages)
      }
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: RepoCell.className, for: indexPath) as! RepoCell
      cell.render(with: data)
      
      if case RepoCellType.readme = data {
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.reloadClosure = { [weak self] in
          Task {
            await self?.fetchReadme()
          }
        }
      } else {
        cell.accessoryType = .disclosureIndicator
      }
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSouce[indexPath.row].height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let type = self.dataSouce[indexPath.row]
    switch type {
    case .language:
      self.navigationController?.pushToRepoContent(with: userName, repoName: repoName)
    case .issues:
      self.navigationController?.pushToRepoIssues(with: userName, repoName: repoName)
    case .pull:
      self.navigationController?.pushToRepoIssues(with: userName, repoName: repoName, issueState: .pull)
    default:
      break
    }
  }
  
}

extension RepoViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > NormalHeaderView.defaultFrame.size.height {
      self.navigationItem.title = self.repo?.name
    } else {
      self.navigationItem.title = "Repository"
    }
  }
}

extension RepoCellType {
  var height: CGFloat {
    switch self {
    case .blank: return 12
    case .primaryLanguage: return 55
    default: return 44
    }
  }

  var imageName: String {
    switch self {
    case .language: return "coding"
    case .issues: return "issue"
    case .pull: return "pull-request"
    case .branch: return "git-branch"
    case .readme: return "book"
    default: return ""
    }
  }
  
  var name: String {
    switch self {
    case .language(let language, _): return language
    case .issues: return "Issues"
    case .pull: return "Pull Requests"
    case .branch: return "Branches"
    case .readme: return "README"
    default: return ""
    }
  }
  
  var desc: String {
    switch self {
    case .language(_, let desc): return desc
    case .issues(let desc): return desc
    case .branch(let desc): return desc
    case .pull(let desc): return desc
    default: return ""
    }
  }

  var showReload: Bool {
    switch self {
    case .readme: return true
    default: return false
    }
  }
}
