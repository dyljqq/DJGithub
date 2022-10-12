//
//  FeedsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import UIKit

class FeedsViewController: UIViewController, NextPageLoadable {
  
  typealias DataType = Feed
  
  var dataSource: [DataType] = []
  var nextPageState: NextPageState = NextPageState()
  
  var feeds: Feeds?

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.register(FeedCell.classForCoder(), forCellReuseIdentifier: FeedCell.className)
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
    
    view.startLoading()
    nextPageState.update(start: 1, hasNext: true, isLoading: false)
    
    Task {
      self.feeds = await FeedManager.getFeeds()
      if let _ = self.feeds {
        tableView.addHeader { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.nextPageState.update(start: 1, hasNext: true, isLoading: false)
          strongSelf.loadNext(start: strongSelf.nextPageState.start)
        }
        tableView.addFooter { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.loadNext(start: strongSelf.nextPageState.start + 1)
        }
        self.loadNext(start: nextPageState.start)
      } else {
        self.view.stopLoading()
      }
    }
  }
  
  func loadNext(start: Int) {
    self.loadNext(start: start) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.view.stopLoading()
      strongSelf.tableView.dj_endRefresh()
      strongSelf.tableView.reloadData()
    }
  }
  
  func performLoad(successHandler: @escaping ([DataType], Bool) -> (), failureHandler: @escaping (String) -> ()) {
    guard let feeds = self.feeds else {
      failureHandler("no valid url.")
      return
    }
    Task {
      let page = self.nextPageState.start
      let urlString = "\(feeds.currentUserUrl)&page=\(page)"
      if let feedInfo = await FeedManager.fetchFeedInfo(with: urlString) {
        successHandler(feedInfo.entry, !feedInfo.entry.isEmpty)
      } else {
        failureHandler("fetch feeds error: \(urlString)")
      }
    }
  }

}

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.className, for: indexPath) as! FeedCell
    cell.render(with: dataSource[indexPath.row])
    cell.tappedClosure = { [weak self] pushType in
      guard let strongSelf = self else { return }
      switch pushType {
      case .repo(let repoName): strongSelf.navigationController?.pushToRepo(with: repoName)
      case .user(let userName): strongSelf.navigationController?.pushToUser(with: userName)
      case .unknown: break
      }
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let feed = dataSource[indexPath.row]
    if let eventName = feed.eventName, let path = feed.link?.path {
      switch eventName {
      case "Follow":
        self.navigationController?.pushToUser(with: path)
      case "Release":
        self.navigationController?.pushToWebView(with: feed.link?.href)
      default:
        self.navigationController?.pushToRepo(with: path)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let feed = dataSource[indexPath.row]
    let height = FeedCell.cellHeight(with: feed)
    return height
  }
  
}
