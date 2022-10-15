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
  }
  
  private func loadData() {
    Task {
      let atoms = await ConfigManager.shared.rssFeedManager.loadAtoms()
      var rs: [RssFeedAtomModel] = []
      for atom in atoms {
        let str = RssFeedAtom.totalFeedsStr(with: atom.id)
        rs.append(RssFeedAtomModel(readStr: str, atom: atom))
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
      content: model.atom.des.isEmpty ? "No description provided." : model.atom.des,
      readStr: model.readStr)
    )
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let model = self.dataSource[indexPath.row]
    return RssFeedSimpleCell.cellHeight(by: model.atom.title, content: model.atom.des)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = dataSource[indexPath.row]
    if model.atom.hasFeeds {
      self.navigationController?.pushToRssFeeds(with: dataSource[indexPath.row].atom)
    } else {
      let vc = UIAlertController(title: "", message: "The feeds is now on downloading.", preferredStyle: .alert)
      self.present(vc, animated: true)
      
      DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
        DispatchQueue.main.async {
          vc.dismiss(animated: true)
        }
      })
    }
  }
}
