//
//  LocalDevelopersViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class LocalDevelopersViewController: UIViewController {

  let type: LocalDataType

  lazy var viewModel: LocalDataViewModel = {
    return LocalDataViewModel(type: type)
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.sectionHeaderHeight = 44
    tableView.sectionHeaderTopPadding = 0
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView()
    tableView.register(LocalDeveloperCell.classForCoder(), forCellReuseIdentifier: LocalDeveloperCell.className)
    tableView.register(LocalRepoCell.classForCoder(), forCellReuseIdentifier: LocalRepoCell.className)
    return tableView
  }()

  var dataSource: [DJCodable] = [] {
    didSet {
      self.view.stopLoading()
      self.tableView.reloadData()
    }
  }

  init(with type: LocalDataType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }

    switch type {
    case .repo: tableView.rowHeight = 64
    case .developer: tableView.rowHeight = 50
    }

    view.startLoading()
    updateLocalData()

    NotificationCenter.default.addObserver(
      forName: DeveloperGroupManager.NotificationUpdatedAllName,
      object: nil,
      queue: OperationQueue.main,
      using: { [weak self] _ in
        guard let strongSelf = self else { return }
        strongSelf.updateLocalData()
    })
  }

  func updateLocalData() {
    Task {
      self.dataSource = await viewModel.loadData()
    }
  }
}

extension LocalDevelopersViewController: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let group = dataSource[section]
    switch type {
    case .repo: return (group as! LocalRepoGroup).repos.count
    case .developer: return (group as! LocalDeveloperGroup).developers.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let group = dataSource[indexPath.section]
    switch type {
    case .repo:
      let cell = tableView.dequeueReusableCell(withIdentifier: LocalRepoCell.className, for: indexPath) as! LocalRepoCell
      let repo = (group as! LocalRepoGroup).repos[indexPath.row]
      cell.render(with: repo)
      return cell
    case .developer:
      let cell = tableView.dequeueReusableCell(withIdentifier: LocalDeveloperCell.className, for: indexPath) as! LocalDeveloperCell
      let developer = (group as! LocalDeveloperGroup).developers[indexPath.row]
      cell.render(with: developer)
      return cell
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let group = dataSource[indexPath.section]
    switch self.type {
    case .repo:
      let repo = (group as! LocalRepoGroup).repos[indexPath.row]
      let arr = repo.id.components(separatedBy: "/")
      if arr.count == 2 {
        self.navigationController?.pushToRepo(with: arr[0], repoName: arr[1])
      }
    case .developer:
      let user = (group as! LocalDeveloperGroup).developers[indexPath.row]
      self.navigationController?.pushToUser(with: user.name)
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = LocalDeveloperSectionHeaderView()
    view.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 30)
    let group = dataSource[section]
    let title: String
    switch type {
    case .repo:
      title = (group as! LocalRepoGroup).name
    case .developer:
      title = (group as! LocalDeveloperGroup).name
    }
    view.render(with: title)
    return view
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch type {
    case .developer: return 50
    case .repo:
      let group = dataSource[indexPath.section]
      let title = (group as! LocalRepoGroup).repos[indexPath.row].description
      let rect = (title as NSString).boundingRect(
        with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
        options: .usesLineFragmentOrigin,
        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
        context: nil)
      return rect.height + 44
    }
  }
}
