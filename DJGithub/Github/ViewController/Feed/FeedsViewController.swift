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

  var feedViewModel: FeedViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .backgroundColor
    tableView.showsVerticalScrollIndicator = false
    tableView.register(FeedCell.classForCoder(), forCellReuseIdentifier: FeedCell.className)
    return tableView
  }()

  init() {
    feedViewModel = FeedViewModel()
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
    navigationItem.title = "News"
    view.backgroundColor = .backgroundColor

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    view.startLoading()
    feedViewModel.feedInfoObserver.bind { [weak self] feedInfo in
      guard let strongSelf = self, let feedInfo else { return }
      DispatchQueue.main.async {
        strongSelf.dataSource = feedInfo.entry
        strongSelf.reloadData()
      }
    }

    if let feedInfo = feedViewModel.fetchLocalFeedInfo() {
      feedViewModel.feedInfoObserver.value = feedInfo
    }

    Task {
      if let feedInfo = await feedViewModel.asyncFetchFeedInfo() {
        feedViewModel.feedInfoObserver.value = feedInfo
      } else {
        view.stopLoading()
      }
    }

    tableView.addHeader { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.nextPageState.update(start: 1, hasNext: true, isLoading: false)
      strongSelf.loadNext(start: strongSelf.nextPageState.start)
    }
    tableView.addFooter { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.loadNext(start: strongSelf.nextPageState.start + 1)
    }
  }

  func loadNext(start: Int) {
    self.loadNext(start: start) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.reloadData()
    }
  }

  private func reloadData() {
    view.stopLoading()
    tableView.dj_endRefresh()
    tableView.reloadData()
  }

  func performLoad(successHandler: @escaping ([DataType], Bool) -> Void, failureHandler: @escaping (String) -> Void) {
    guard let feeds = self.feedViewModel.feeds else {
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
      case .repo(let repoName):
        if let (userName, repoName) = repoName.splitRepoFullName {
          strongSelf.navigationController?.pushToRepo(with: userName, repoName: repoName)
        }
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
        if let (userName, repoName) = path.splitRepoFullName {
          self.navigationController?.pushToRepo(with: userName, repoName: repoName)
        }
      }
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let feed = dataSource[indexPath.row]
    let height = FeedCell.cellHeight(with: feed)
    return height
  }

}
