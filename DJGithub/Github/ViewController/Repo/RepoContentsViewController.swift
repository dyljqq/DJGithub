//
//  RepoContentsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

class RepoContentsViewController: UIViewController {

  let userName: String
  let repoName: String
  
  var loadingQueue: [Int: Bool] = [:]
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .backgroundColor
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 44
    tableView.tableFooterView = UIView()
    tableView.register(RepoContentCell.classForCoder(), forCellReuseIdentifier: RepoContentCell.className)
    return tableView
  }()
  
  init(with userName: String, repoName: String) {
    self.userName = userName
    self.repoName = repoName
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var dataSource: [RepoContent] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }

  private func setUp() {
    view.backgroundColor = .backgroundColor
    self.navigationItem.title = self.repoName
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    
    Task {
      let repoContents = await RepoManager.getRepoContent(with: self.userName, repoName: self.repoName)
      self.dataSource = repoContents.reversed()
      self.tableView.reloadData()
    }
  }
  
  private func update(with repoContent: RepoContent, indexPath: IndexPath) {
    guard repoContent.isDir else {
      return
    }
    
    if repoContent.isExpanded {
      var offset = indexPath.row + 1
      while offset < self.dataSource.count {
        let content = self.dataSource[offset]
        if content.deepLength == repoContent.deepLength {
          break
        }
        offset += 1
      }
      let range = (indexPath.row + 1)..<(offset)
      self.dataSource.removeSubrange(range)
      self.dataSource[indexPath.row].isExpanded = false
      self.tableView.reloadData()
    } else {
      guard !loadingQueue[indexPath.row, default: false] else {
        return
      }
      loadingQueue[indexPath.row] = true
      Task {
        var contents = await RepoManager.getRepoContent(with: repoContent.url)
        contents = contents.map { content in
          var c = content
          c.deepLength = repoContent.deepLength + 1
          return c
        }
        self.dataSource[indexPath.row].isExpanded = true
        self.dataSource[indexPath.row].contents = contents
        if indexPath.row + 1 < self.dataSource.count {
          self.dataSource.insert(contentsOf: contents, at: indexPath.row + 1)
        }
        self.tableView.reloadData()
        loadingQueue[indexPath.row] = false
      }
    }
  }
}

extension RepoContentsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RepoContentCell.className, for: indexPath) as! RepoContentCell
    let repoContent = self.dataSource[indexPath.row]
    cell.render(with: repoContent)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let repoContent = self.dataSource[indexPath.row]
    switch repoContent.type {
    case .dir:
      update(with: repoContent, indexPath: indexPath)
    case .file:
      self.navigationController?.pushToRepoContentFile(with: repoContent.url)
    }
  }
  
}
