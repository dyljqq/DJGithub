//
//  RssFeedsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedsViewController: UIViewController {

  let rssFeedAtom: RssFeedAtom
  
  var dataSource: [RssFeed] = []
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.register(RssFeedAtomCell.classForCoder(), forCellReuseIdentifier: RssFeedAtomCell.className)
    return tableView
  }()
  
  init(with rssFeedAtom: RssFeedAtom) {
    self.rssFeedAtom = rssFeedAtom
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
    view.backgroundColor = .backgroundColor
    navigationItem.title = rssFeedAtom.title
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    view.startLoading()
    
    Task {
      self.dataSource = await FeedManager.fetchRssFeeds(with: rssFeedAtom.feedLink)
      view.stopLoading()
      self.tableView.reloadData()
    }
  }

}

extension RssFeedsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RssFeedAtomCell.className, for: indexPath) as! RssFeedAtomCell
    let rssFeed = self.dataSource[indexPath.row]
    cell.render(with: rssFeed.title, des: rssFeed.updated)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let feed = self.dataSource[indexPath.row]
    return RssFeedAtomCell.cellHeight(by: feed.title, content: feed.updated)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    // TODO
  }
}
