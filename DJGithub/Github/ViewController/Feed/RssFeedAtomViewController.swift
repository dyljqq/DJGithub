//
//  RssFeedViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedAtomViewController: UIViewController {

  struct RssFeedAtomModel {
    var readStr: String
    let atom: RssFeedAtom
    let layout: RssFeedSimpleCellLayout

    mutating func update(_ readStr: String) {
      self.readStr = readStr
    }

    var simpleModel: RssFeedSimpleCell.RssFeedSimpleModel {
      return RssFeedSimpleCell.RssFeedSimpleModel(
        title: atom.title, content: atom.des, readStr: readStr
      )
    }
  }

  var dataSource: [RssFeedAtomModel] = []

  lazy var headerView: RssFeedLatestView = {
    let view = RssFeedLatestView()
    view.didSelectItemClosure = { [weak self] feedId in
      if let feed = RssFeed.get(by: feedId) as RssFeed? {
        Task {
          await feed.updateReadStatus()
          NotificationCenter.default.post(name: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: ["atomId": feed.atomId])
        }
        self?.navigationController?.pushToRssFeedDetial(with: feed)
      }
    }
    return view
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.register(RssFeedSimpleCell.classForCoder(), forCellReuseIdentifier: RssFeedSimpleCell.className)
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    Task {
      if let models = try? await RssFeedManager.shared.asyncLoadLatestFeeds(), !models.isEmpty {
        headerView.render(with: models)
      }
    }
  }

  private func setUp() {
    self.navigationItem.title = "Rss"
    view.backgroundColor = .backgroundColor

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))

    view.addSubview(headerView)
    view.addSubview(tableView)
    headerView.snp.makeConstraints { make in
      make.height.equalTo(132)
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.leading.trailing.equalToSuperview()
    }
    tableView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }

    view.startLoading()
    self.loadData()
    self.addNotification()

    RssFeedManager.shared.finishedLoadFeeds = { [weak self] feeds in
      guard let strongSelf = self else { return }
      DispatchQueue.main.async {
        strongSelf.headerView.render(with: feeds)
      }
    }
  }

  private func addNotification() {
    NotificationCenter.default.removeObserver(self, name: RssFeedManager.RssFeedAtomUpdateNotificationKey, object: nil)
    NotificationCenter.default.removeObserver(self, name: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: nil)

    NotificationCenter.default.addObserver(
      forName: RssFeedManager.RssFeedAtomUpdateNotificationKey,
      object: nil,
      queue: .main,
      using: { [weak self] notification in
        guard let strongSelf = self else { return }
        if let dict = notification.object as? [String: Any],
        let feedLink = dict["feedLink"] as? String {
          for (index, model) in strongSelf.dataSource.enumerated() {
            if model.atom.feedLink == feedLink {
              if let atom = RssFeedAtom.getByFeedLink(feedLink) {
                strongSelf.dataSource[index] = RssFeedAtomModel(readStr: model.readStr, atom: atom, layout: model.layout)
                strongSelf.tableView.reloadData()
                return
              }
            }
          }
        }
    })
    NotificationCenter.default.addObserver(forName: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: nil, queue: .main, using: { [weak self] notification in
      guard let strongSelf = self,
      let dict = notification.object as? [String: Any],
      let atomId = dict["atomId"] as? Int else { return }
      for (index, model) in strongSelf.dataSource.enumerated() {
        if model.atom.id == atomId,
           let atom = RssFeedAtom.get(by: atomId) {
          strongSelf.dataSource[index] = RssFeedAtomModel(
            readStr: RssFeedManager.shared.totalFeedsReadStr(with: atom.id),
            atom: atom,
            layout: model.layout
          )
          strongSelf.tableView.reloadData()
          return
        }
      }
    })
  }

  private func loadData() {
    Task {
      await self.configDataSource()
    }
  }

  private func configDataSource() async {
    let atoms = await RssFeedManager.shared.loadAtoms()
    configDataSource(with: atoms)
    Task {
      if let mapping = await RssFeedManager.shared.asyncLoadReadMapping() {
        configDataSource(with: atoms, mapping: mapping)
      }
    }
  }

  private func configDataSource(with atoms: [RssFeedAtom], mapping: [Int: (Int, Int)] = [:]) {
    dataSource = atoms.map { atom in
      let readStr: String
      if let (total, readCount) = mapping[atom.id] {
        readStr = "\(readCount)/\(total)"
      } else {
        readStr = ""
      }
      return RssFeedAtomModel(readStr: readStr, atom: atom, layout: RssFeedSimpleCellLayout(with: atom.title, content: atom.des))
    }
    view.stopLoading()
    self.tableView.reloadData()
  }

  @objc func addAction() {
    let vc = TitleAndDescViewController(with: .rssFeed)
    vc.completionHandler = { [weak self] in
      self?.loadData()
    }
    self.present(vc, animated: true)
  }

}

extension RssFeedAtomViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RssFeedSimpleCell.className, for: indexPath) as! RssFeedSimpleCell
    cell.render(with: self.dataSource[indexPath.row].simpleModel)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let model = self.dataSource[indexPath.row]
    return model.layout.totalHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let model = dataSource[indexPath.row]
    self.navigationController?.pushToRssFeeds(with: model.atom)
  }
}
