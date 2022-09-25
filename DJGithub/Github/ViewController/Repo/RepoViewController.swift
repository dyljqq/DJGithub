//
//  RepoViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

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
  
  var dataSouce: [CellType] = []
  
  lazy var headerView: RepoHeaderView = {
    let headerView = RepoHeaderView()
    return headerView
  }()
  
  lazy var starButton: UIButton = {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    button.setTitle("star", for: .normal)
    button.setTitleColor(UIColor.blue, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.addTarget(self, action: #selector(starAction), for: .touchUpInside)
    button.layer.cornerRadius = 15
    button.backgroundColor = .backgroundColor
    return button
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .backgroundColor
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
    
    Task {
      let star = await RepoViewModel.userStaredRepo(with: repoName)
      configStarButton(star)
      if let repo =  await RepoViewModel.fetchRepo(with: repoName) {
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
    }
  }
  
  func configStarButton(_ isStar: Bool) {
    let title = isStar ? "unstar" : "star"
    DispatchQueue.global().async {
      let width = NSString(string: title).boundingRect(with: CGSize(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil).width
      DispatchQueue.main.async {
        let width = NSString(string: title).boundingRect(with: CGSize(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil).width
        self.starButton.frame.size.width = width + 30
        self.starButton.setTitle(title, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.starButton)
      }
    }
  }
  
  @objc func starAction() {
    
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
