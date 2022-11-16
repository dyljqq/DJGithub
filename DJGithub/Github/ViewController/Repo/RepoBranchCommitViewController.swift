//
//  RepoBranchCommitViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import UIKit
import SafariServices

class RepoBranchCommitViewController: UIViewController {

  // 分支名
  let head: String
  // master
  let base: String
  let urlString: String

  var showCommitButton: Bool = false {
    didSet {
      createButton.isHidden = !showCommitButton
    }
  }

  var branchCommit: RepoBranchCommitInfo?
  var files: [RepoPullFile] = []

  lazy var compareLabel: UILabel = {
    let label = UILabel()
    label.text = "compare: \(head)"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textColor
    return label
  }()

  lazy var baseLabel: UILabel = {
    let label = UILabel()
    label.text = "base: \(base)"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .textColor
    return label
  }()

  lazy var commitUserView: RepoBranchCommitUserView = {
    let view = RepoBranchCommitUserView()
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColorFromRGB(0xeeeeee).cgColor
    view.layer.cornerRadius = 5
    return view
  }()

  lazy var descLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()

  lazy var headerView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 150))
    return view
  }()

  lazy var lineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColorFromRGB(0xeeeeee)
    return view
  }()

  lazy var createButton: UIButton = {
    let createButton = UIButton()
    createButton.backgroundColor = UIColor(red: 66.0 / 255, green: 150.0 / 255, blue: 77.0 / 255, alpha: 1)
    createButton.layer.cornerRadius = 5
    createButton.setTitle("Create pull request", for: .normal)
    createButton.setTitleColor(.white, for: .normal)
    createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
    return createButton
  }()

  lazy var footerView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 80))
    view.addSubview(createButton)
    createButton.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.equalTo(40)
      make.height.equalTo(44)
    }
    return view
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerView
    tableView.rowHeight = 60
    tableView.register(RepoBranchCommitFileCell.classForCoder(), forCellReuseIdentifier: RepoBranchCommitFileCell.className)
    return tableView
  }()

  init(head: String, base: String, urlString: String) {
    self.head = head
    self.base = base
    self.urlString = urlString
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }

  private func fetchRepoBranchCommitInfo() {
    Task {
      if let info = await RepoManager.fetchRepoBranchCommit(with: urlString) {
        self.branchCommit = info
        commitUserView.render(with: info)

        if let stats = info.stats {
          let text = "Showing \(info.displayedFiles.count) changed files with \(stats.additions) additions and \(stats.deletions) deletions."
          let attr = NSMutableAttributedString(string: text)
          if let changedRange = text.range(of: "\(info.displayedFiles.count) changed files") {
            let range = NSRange(changedRange, in: text)
            attr.addAttribute(.foregroundColor, value: UIColor.lightBlue, range: range)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
          }
          if let additionRange = text.range(of: "\(stats.additions) additions") {
            let range = NSRange(additionRange, in: text)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
          }
          if let deletionRange = text.range(of: "\(stats.deletions) deletions") {
            let range = NSRange(deletionRange, in: text)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: range)
          }
          descLabel.attributedText = attr
        }

        self.files = info.displayedFiles
        self.tableView.reloadData()
      }
    }
  }

  private func setUp() {
    self.navigationItem.title = "Comparing changes"

    view.backgroundColor = .white
    headerView.addSubview(compareLabel)
    headerView.addSubview(baseLabel)
    headerView.addSubview(commitUserView)
    headerView.addSubview(descLabel)
    headerView.addSubview(lineView)
    view.addSubview(tableView)

    baseLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
    }
    compareLabel.snp.makeConstraints { make in
      make.leading.equalTo(baseLabel.snp.trailing).offset(20)
      make.top.equalTo(baseLabel)
    }
    commitUserView.snp.makeConstraints { make in
      make.top.equalTo(baseLabel.snp.bottom).offset(10)
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.height.equalTo(60)
    }
    descLabel.snp.makeConstraints { make in
      make.top.equalTo(commitUserView.snp.bottom).offset(10)
      make.leading.equalTo(baseLabel)
      make.trailing.equalTo(-12)
    }
    lineView.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.height.equalTo(0.5)
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    let baseText = "base: \(base)"
    let baseAttr = NSMutableAttributedString(string: baseText)
    baseAttr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 6, length: base.count))
    baseAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: NSRange(location: 6, length: base.count))
    baseLabel.attributedText = baseAttr

    let compareText = "compare: \(head)"
    let compareAttr = NSMutableAttributedString(string: compareText)
    compareAttr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 9, length: head.count))
    compareAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: NSRange(location: 9, length: head.count))
    compareLabel.attributedText = compareAttr

    fetchRepoBranchCommitInfo()
  }

  @objc func createAction() {
    if let branchCommit = branchCommit,
       let repoName = getRepoName(by: urlString),
       let author = branchCommit.author,
       let committer = branchCommit.committer {
      let model = PullRequestModel(
        title: branchCommit.commit.message,
        userName: author.login,
        repoName: repoName,
        base: base,
        compare: head,
        commiterName: committer.login
      )
      let vc = TitleAndDescViewController(with: .createPullRequest(model: model))
      self.present(vc, animated: true)
      vc.completionHandler = { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

extension RepoBranchCommitViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RepoBranchCommitFileCell.className, for: indexPath) as! RepoBranchCommitFileCell
    cell.render(with: files[indexPath.row])
    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return files.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let file = files[indexPath.row]
    if let url = URL(string: file.blobUrl) {
      let vc = SFSafariViewController(url: url)
      self.present(vc, animated: true)
    }
  }
}

extension RepoBranchCommitViewController {
  private func getRepoName(by urlString: String) -> String? {
    let components = URLComponents(string: urlString)
    if let path = components?.path {
      let arr = path.components(separatedBy: "/").filter { !$0.isEmpty }
      if arr.count == 5 {
        return arr[2]
      }
    }
    return nil
  }
}
