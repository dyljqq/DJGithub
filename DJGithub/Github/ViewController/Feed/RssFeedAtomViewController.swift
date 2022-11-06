//
//  RssFeedViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedAtomViewController: UIViewController {

  struct RssFeedAtomModel {
    let readStr: String
    let atom: RssFeedAtom
    let layout: RssFeedSimpleCellLayout
  }
  
  var dataSource: [RssFeedAtomModel] = []
  
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
  }
  
  private func setUp() {
    self.navigationItem.title = "Rss"
    view.backgroundColor = .backgroundColor
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    view.startLoading()
    self.loadData()
    
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
    self.configDataSource()
    RssFeedManager.shared.loadedFeedsFinishedClosure = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.configDataSource()
    }
  }
  
  private func configDataSource() {
    Task {
      let atoms = await RssFeedManager.shared.loadAtoms()
      var rs: [RssFeedAtomModel] = []
      for atom in atoms {
        let str = RssFeedManager.shared.totalFeedsReadStr(with: atom.id)
        let layout = RssFeedSimpleCellLayout(with: atom.title, content: atom.des)
        rs.append(RssFeedAtomModel(readStr: str, atom: atom, layout: layout))
      }
      dataSource = rs
      view.stopLoading()
      self.tableView.reloadData()
    }
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
    let model = self.dataSource[indexPath.row]
    cell.render(with: RssFeedSimpleCell.RssFeedSimpleModel(
      title: model.atom.title,
      content: model.atom.des,
      readStr: model.readStr)
    )
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
