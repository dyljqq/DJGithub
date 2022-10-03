//
//  LocalDevelopersViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class LocalDevelopersViewController: UIViewController {

  var dataSource: [LocalDeveloperGroup] = []
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 50
    tableView.sectionHeaderHeight = 44
    tableView.sectionHeaderTopPadding = 0
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView()
    tableView.register(LocalDeveloperCell.classForCoder(), forCellReuseIdentifier: LocalDeveloperCell.className)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    
    update()
    
    NotificationCenter.default.addObserver(forName: DeveloperGroupManager.NotificationUpdatedAllName, object: nil, queue: .main, using: { [weak self] notification in
      guard let strongSelf = self else { return }
      strongSelf.update()
    })
  }
  
  func update() {
    Task {
      dataSource = await DeveloperGroupManager.shared.loadFromDatabase()
      if dataSource.isEmpty {
        dataSource = await DeveloperGroupManager.shared.loadLocalDeveloperGroups()
      }
      tableView.reloadData()
    }
  }

}

extension LocalDevelopersViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let group = dataSource[section]
    return group.developers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LocalDeveloperCell.className, for: indexPath) as! LocalDeveloperCell
    let developer = dataSource[indexPath.section].developers[indexPath.row]
    cell.render(with: developer)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let user = self.dataSource[indexPath.section].developers[indexPath.row]
    self.navigationController?.pushToUser(with: user.name)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = LocalDeveloperSectionHeaderView()
    view.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 30)
    view.render(with: self.dataSource[section].name)
    return view
  }
}
