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
    
    Task {
      do {
        dataSource = try await UserManager.loadLocalDevelopersAsync()
        tableView.reloadData()
      } catch {
        print("fetch local developers error: \(error)")
      }
    }
  }

}

extension LocalDevelopersViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let group = dataSource[section]
    return group.users.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return dataSource[section].name
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LocalDeveloperCell.className, for: indexPath) as! LocalDeveloperCell
    let developer = dataSource[indexPath.section].users[indexPath.row]
    cell.render(with: developer)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let user = self.dataSource[indexPath.section].users[indexPath.row]
    self.navigationController?.pushToUser(with: user.id)
  }
}
