//
//  RssFeedsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedsViewController: UIViewController {

  let rssFeedAtom: RssFeedAtom

  var dataSource: [RssFeedsViewControllerModel] = []

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.register(RssFeedSimpleCell.classForCoder(), forCellReuseIdentifier: RssFeedSimpleCell.className)
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

    self.loadLocalFeeds()
    Task {
      let isUpdated = await RssFeedManager.shared.loadFeeds(by: rssFeedAtom)
      if isUpdated {
        self.loadLocalFeeds()
      }
    }

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAtomAction))
  }

  private func loadLocalFeeds() {
    Task {
      RssFeedManager.shared.loadFeedReadMapping(with: self.rssFeedAtom.id)
      let feeds = await RssFeedManager.getFeeds(by: rssFeedAtom.id)
      self.dataSource = feeds.map { RssFeedsViewControllerModel(model: $0, layout: RssFeedSimpleCellLayout(with: $0.title, content: $0.displayDateString)) }
      view.stopLoading()
      self.tableView.reloadData()
    }
  }

  @objc func editAtomAction() {
    let vc = TitleAndDescViewController(with: .editRssFeedAtom(title: rssFeedAtom.title, description: rssFeedAtom.des, feedLink: rssFeedAtom.feedLink))
    vc.completionHandler = { [weak self] in
      guard let strongSelf = self else { return }
      if let atom = RssFeedAtom.getByFeedLink(strongSelf.rssFeedAtom.feedLink) {
        strongSelf.navigationItem.title = atom.title
      }
    }
    self.present(vc, animated: true)
  }
}

extension RssFeedsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RssFeedSimpleCell.className, for: indexPath) as! RssFeedSimpleCell
    let rssFeed = self.dataSource[indexPath.row].model
    let model = RssFeedSimpleCell.RssFeedSimpleModel(title: rssFeed.title, content: rssFeed.displayDateString, unread: rssFeed.unread)
    cell.render(with: model)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let feed = self.dataSource[indexPath.row]
    return feed.layout.totalHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let rssFeed = dataSource[indexPath.row].model
    self.navigationController?.pushToRssFeedDetial(with: rssFeed)

    Task {
      await rssFeed.updateReadStatus()
      DispatchQueue.main.async {
        self.tableView.reloadData()
        NotificationCenter.default.post(name: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: ["atomId": self.rssFeedAtom.id])
      }
    }
  }
}

extension RssFeed {
  var displayDateString: String {
    return "updated on \(self.updated.components(separatedBy: " ").first ?? self.updated)"
  }
}

extension RssFeedsViewController {
  struct RssFeedsViewControllerModel {
    let model: RssFeed
    let layout: RssFeedSimpleCellLayout
  }
}
