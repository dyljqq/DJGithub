//
//  PamphletResourceViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

class PamphletResourceViewController: UIViewController {

  let naviTitle: String
  let filename: String

  var dataSource: [CellLayout] = []

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(PamphletResourceCell.classForCoder(), forCellReuseIdentifier: PamphletResourceCell.className)
    return tableView
  }()

  init(naviTitle: String, filename: String) {
    self.naviTitle = naviTitle
    self.filename = filename
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
    navigationItem.title = naviTitle
    view.backgroundColor = .backgroundColor

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    Task {
      let items: [PamphletResourceModel] = loadBundleJSONFile(filename)
      var layouts: [CellLayout] = []
      for item in items {
        let layout = await convert(item)
        layouts.append(layout)
      }
      dataSource = layouts
      tableView.reloadData()
    }
  }

}

extension PamphletResourceViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PamphletResourceCell.className, for: indexPath) as! PamphletResourceCell
    cell.render(with: dataSource[indexPath.row].model)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSource[indexPath.row].height
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let model = dataSource[indexPath.row]
    URLRouter.open(with: model.model.url)
  }
}

extension PamphletResourceViewController {
  struct CellLayout {
    let model: PamphletResourceModel
    let height: CGFloat
  }

  func convert(_ item: PamphletResourceModel) async -> CellLayout {
    let titleHeight = (item.title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [.font: UIFont.systemFont(ofSize: 14)],
      context: nil
    ).height
    let descHeight = (item.desc as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [.font: UIFont.systemFont(ofSize: 12)],
      context: nil
    ).height
    let height = titleHeight + descHeight + 25
    return CellLayout(model: item, height: height)
  }
}
