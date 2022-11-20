//
//  PamphletViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

class PamphletViewController: UIViewController {

  let type: VCType

  init(type: VCType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var dataSource: [PamphletSectionModel] = []

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.rowHeight = 44
    tableView.delegate = self
    tableView.dataSource = self
    tableView.sectionHeaderTopPadding = 0
    tableView.showsVerticalScrollIndicator = false
    tableView.register(PamphletSimpleCell.classForCoder(), forCellReuseIdentifier: PamphletSimpleCell.className)
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .backgroundColor
    setUp()
  }

  private func setUp() {
    navigationItem.title = "Pamphlet"

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    Task {
      dataSource = await type.loadData()
      self.tableView.reloadData()
    }
  }

}

extension PamphletViewController: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let model = dataSource[section]
    return model.items.count
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 30))

    let label = UILabel()
    label.text = dataSource[section].sectionName
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    view.addSubview(label)

    label.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.centerY.equalToSuperview()
    }

    return view
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PamphletSimpleCell.className, for: indexPath) as! PamphletSimpleCell
    cell.render(with: dataSource[indexPath])
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let model = dataSource[indexPath]
    URLRouter.open(with: model?.jumpUrl)
  }
}

extension PamphletViewController {
  enum VCType {
    case main
    case explore
    case archive
    case resource

    var title: String {
      switch self {
      case .explore: return "探索库"
      case .archive: return "库存档"
      case .resource: return "资料整理"
      case .main: return "Pamphlet"
      }
    }

    var jsonFileName: String? {
      switch self {
      case .main: return "PamphletData"
      case .resource: return "PamphletSectionContentResource"
      default: return ""
      }
    }

    func loadData() async -> [PamphletSectionModel] {
      guard let fileName = jsonFileName else { return [] }
      return loadBundleJSONFile(fileName)
    }
  }
}
