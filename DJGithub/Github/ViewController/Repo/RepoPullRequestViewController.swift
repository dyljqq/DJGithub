//
//  RepoPullRequestViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import UIKit
import SafariServices

class RepoPullRequestViewController: UIViewController {
  
  enum CellType {
    case commits
    case files
    case blank
  }
  
  struct SectionInfo {
    let title: String
    var height: CGFloat = 0
    var attr: NSAttributedString?
    
    init(with title: String) {
      self.title = title
      self.height = calHeight()
    }
    
    func calHeight() -> CGFloat {
      let height = (self.title as NSString).boundingRect(
        with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
        options: .usesLineFragmentOrigin,
        attributes: [.font: UIFont.systemFont(ofSize: 14)],
        context: nil
      ).size.height
      return height + 20
    }
  }

  let userName: String
  let repoName: String
  let pullNum: Int
  
  var pullInfo: RepoPull?
  var commitsSectionInfo: SectionInfo?
  var filesSectionInfo: SectionInfo?
  
  var dataSource: [CellType] = [.blank, .commits, .blank, .files]
  var commits: [RepoBranchCommitInfo] = []
  var files: [RepoPullFile] = []
  
  var canMerge: Bool = false {
    didSet {
      self.mergeButton.isHidden = !canMerge
    }
  }
  
  lazy var headerView: RepoPullRequestHeaderView = {
    let view = RepoPullRequestHeaderView()
    view.backgroundColor = .white
    return view
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = UIView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.sectionHeaderTopPadding = 0
    tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.className)
    tableView.register(RepoBranchCommitCell.classForCoder(), forCellReuseIdentifier: RepoBranchCommitCell.className)
    tableView.register(RepoBranchCommitFileCell.classForCoder(), forCellReuseIdentifier: RepoBranchCommitFileCell.className)
    return tableView
  }()
  
  lazy var mergeButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor(red: 66.0 / 255, green: 150.0 / 255, blue: 77.0 / 255, alpha: 1)
    button.layer.cornerRadius = 5
    button.isHidden = true
    button.setTitle("Merge", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    button.addTarget(self, action: #selector(mergeAction), for: .touchUpInside)
    return button
  }()
  
  init(userName: String, repoName: String, pullNum: Int) {
    self.userName = userName
    self.repoName = repoName
    self.pullNum = pullNum
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  @objc func mergeAction() {
    Task {
      let canMerge = await RepoManager.repoCanMerge(with: userName, repoName: repoName, pullNum: pullNum)
      guard canMerge else {
        let vc = UIAlertController(title: "Hint", message: "This pull request has been merged.", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "sure", style: .default, handler: { [weak self] action in
          self?.dismiss(animated: true)
        }))
        vc.addAction(UIAlertAction(title: "cancel", style: .cancel))
        self.present(vc, animated: true)
        return
      }
      
      // TODO
    }
  }
  
  private func setUp() {
    self.navigationItem.title = "Pull-#\(pullNum)"
    view.addSubview(tableView)
    view.addSubview(mergeButton)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    mergeButton.snp.makeConstraints { make in
      make.leading.equalTo(40)
      make.centerX.equalToSuperview()
      make.height.equalTo(44)
      make.bottom.equalTo(-60)
    }
    
    Task {
      await withThrowingTaskGroup(of: Void.self) { [weak self] group in
        guard let strongSelf = self else { return }
        group.addTask {
          await strongSelf.fetchPullInfo()
        }
        group.addTask {
          await strongSelf.fetchRepoPullFiles()
        }
        group.addTask {
          await strongSelf.fetchRepoPullCommits()
        }
        group.addTask {
          await strongSelf.checkMergeStatus()
        }
      }
    }
  }
  
  private func fetchPullInfo() {
    Task {
      if let info = await RepoManager.getPullRequest(with:userName, repoName:repoName, pullNum:pullNum) {
        self.pullInfo = info
        
        let dateString: String
        if let d = info.updatedAt.components(separatedBy: "T").first {
          dateString = d
        } else {
          dateString = info.updatedAt
        }
        self.commitsSectionInfo = SectionInfo(with: "Commits on \(dateString)")
        
        let text = "Showing \(info.changedFiles) changed files with \(info.additions) additions and \(info.deletions) deletions"
        self.filesSectionInfo = SectionInfo(with: text)
        let attr = NSMutableAttributedString(string: self.filesSectionInfo!.title)
        if let changedRange = text.range(of: "\(info.changedFiles) changed files") {
          let range = NSRange(changedRange, in: text)
          attr.addAttribute(.foregroundColor, value: UIColor.lightBlue, range: range)
          attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
        }
        if let additionRange = text.range(of: "\(info.additions) additions") {
          let range = NSRange(additionRange, in: text)
          attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
        }
        if let deletionRange = text.range(of: "\(info.deletions) deletions") {
          let range = NSRange(deletionRange, in: text)
          attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
        }
        self.filesSectionInfo?.attr = attr
        
        headerView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: headerView.calHeight(with: info))
        headerView.render(with: info)
        tableView.reloadData()
        tableView.beginUpdates()
        tableView.endUpdates()
      }
    }
  }
  
  private func fetchRepoPullCommits() {
    Task {
      self.commits = await RepoManager.fetchRepoPullCommits(with: userName, repoName: repoName, pullNum: pullNum)
      self.tableView.reloadData()
    }
  }
  
  private func fetchRepoPullFiles() {
    Task {
      self.files = await RepoManager.fetchRepoPullFiles(with: userName, repoName: repoName, pullNum: pullNum)
      self.tableView.reloadData()
    }
  }
  
  private func checkMergeStatus() {
    Task {
      self.canMerge = await RepoManager.repoCanMerge(with: userName, repoName: repoName, pullNum: pullNum)
    }
  }

}

extension RepoPullRequestViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 30))
    view.backgroundColor = .white
    
    let lineView = UIView()
    lineView.backgroundColor = UIColorFromRGB(0xeeeeee)
    view.addSubview(lineView)

    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 14)
    titleLabel.textColor = .textColor
    titleLabel.numberOfLines = 0
    view.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.bottom.equalTo(-5)
    }
    lineView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.bottom.equalToSuperview()
      make.height.equalTo(0.5)
      make.trailing.equalToSuperview()
    }
    
    switch dataSource[section] {
    case .commits: titleLabel.text = commitsSectionInfo?.title
    case .files:
      titleLabel.text = filesSectionInfo?.title
      titleLabel.attributedText = filesSectionInfo?.attr
    case .blank: return nil
    }
      
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let type = dataSource[section]
    switch type {
    case .blank: return 0
    case .commits: return commitsSectionInfo?.height ?? 0
    case .files: return filesSectionInfo?.height ?? 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch dataSource[section] {
    case .commits: return commits.count
    case .files: return files.count
    case .blank: return 1
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let type = dataSource[indexPath.section]
    switch type {
    case .commits: return 60
    case .files: return 60
    case .blank: return 10
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let type = dataSource[indexPath.section]
    switch type {
    case .commits:
      let cell = tableView.dequeueReusableCell(withIdentifier: RepoBranchCommitCell.className, for: indexPath) as! RepoBranchCommitCell
      let commit = commits[indexPath.row]
      cell.render(with: commit)
      return cell
    case .blank:
      let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
      cell.backgroundColor = .backgroundColor
      cell.separatorInset = UIEdgeInsets(top: 0, left: FrameGuide.screenWidth, bottom: 0, right: 0)
      return cell
    case .files:
      let cell = tableView.dequeueReusableCell(withIdentifier: RepoBranchCommitFileCell.className, for: indexPath) as! RepoBranchCommitFileCell
      cell.render(with: files[indexPath.row])
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let info = pullInfo else { return }
    
    switch dataSource[indexPath.section] {
    case .commits:
      let urlString = "https://api.github.com/repos/\(userName)/\(repoName)/commits/\(info.head.sha)"
      self.navigationController?.pushToRepoBranchCommit(with: info.base.ref, head: info.head.ref, urlString: urlString)
    case .files:
      let file = files[indexPath.row]
      if let url = URL(string: file.blobUrl) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
      }
    case .blank:
      return
    }
  }
}

class RepoPullRequestHeaderView: UIView {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightBlue
    label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var commentLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textColor
    return label
  }()
  
  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  init() {
    super.init(frame: .zero)
    setUp()
  }
  
  func render(with model: RepoPull) {
    titleLabel.text = model.title
    avatarImageView.setImage(with: model.user.avatarUrl)
    if let date = model.createdAt.components(separatedBy: "T").first {
      commentLabel.text = "\(model.user.login) commented on \(date)"
    } else {
      commentLabel.text = "\(model.user.login) commented on \(model.createdAt)"
    }
    descLabel.text = model.body
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUp() {
    addSubview(titleLabel)
    addSubview(avatarImageView)
    addSubview(descLabel)
    addSubview(commentLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.trailing.equalTo(-12)
    }
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.width.height.equalTo(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
    }
    commentLabel.snp.makeConstraints { make in
      make.centerY.equalTo(avatarImageView)
      make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
      make.trailing.equalTo(-12)
    }
    descLabel.snp.makeConstraints { make in
      make.top.equalTo(avatarImageView.snp.bottom).offset(10)
      make.leading.equalTo(avatarImageView)
      make.trailing.equalTo(commentLabel)
    }
  }
  
}

extension RepoPullRequestHeaderView {
  func calHeight(with model: RepoPull) -> CGFloat {
    let titleHeight = (model.title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [.font: titleLabel.font ?? UIFont.systemFont(ofSize: 16)],
      context: nil
    ).size.height
    let bodyHeight = (model.desc as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [.font: descLabel.font ?? UIFont.systemFont(ofSize: 12)],
      context: nil
    ).size.height
    return titleHeight + bodyHeight + 60
  }
}
