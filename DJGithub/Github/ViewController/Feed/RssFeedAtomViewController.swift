//
//  RssFeedViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedAtomViewController: UIViewController {

  var dataSource: [RssFeedAtom] = []
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.register(RssFeedAtomCell.classForCoder(), forCellReuseIdentifier: RssFeedAtomCell.className)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    dataSource = loadBundleJSONFile("rssfeed")
    self.tableView.reloadData()
  }

}

extension RssFeedAtomViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RssFeedAtomCell.className, for: indexPath) as! RssFeedAtomCell
    let atom = self.dataSource[indexPath.row]
    cell.render(with: atom.title, des: atom.des)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let atom = self.dataSource[indexPath.row]
    return RssFeedAtomCell.cellHeight(by: atom.title, content: atom.des)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.navigationController?.pushToRssFeeds(with: dataSource[indexPath.row])
  }
}