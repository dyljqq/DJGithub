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

  var dataSource: [CellModel] = []

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

    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
      AppStyleUtility.shared.open(with: .gray)
    })
  }

  private func setUp() {
    navigationItem.title = type.title

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    Task {
      let items = await type.loadData()
      dataSource = items.map { CellModel.convert(with: $0) }
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
    view.backgroundColor = .white

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

    guard let model = dataSource[indexPath] else { return }
    let originModel = dataSource[indexPath.section].originModel
    if type == VCType.resource {
      let filename = "D-\(model.title)"
      let vc = PamphletResourceViewController(naviTitle: model.title, filename: filename)
      self.navigationController?.pushViewController(vc, animated: true)
    } else if originModel.type == PamphletSectionModel.PSType.issue {
      let url = "djgithub://githubIssue?userName=ming1016&repoName=SwiftPamphletApp&issueNumber=\(model.issueNumber)"
      URLRouter.open(with: url)
    } else {
      URLRouter.open(with: model.jumpUrl)
    }
  }
}

extension PamphletViewController {
  enum VCType: String {
    case main
    case explore
    case archive
    case resource
    case guideSyntax
    case guideFeatures
    case guideSubject
    case swiftUI
    case combine
    case concurrency

    var title: String {
      switch self {
      case .explore: return "探索库"
      case .archive: return "库存档"
      case .resource: return "资料整理"
      case .main: return "Pamphlet"
      case .guideSyntax: return "语法速查"
      case .guideFeatures: return "特性"
      case .guideSubject: return "专题"
      case .swiftUI: return "SwiftUI"
      case .combine: return "Combine"
      case .concurrency: return "Concurrency"
      }
    }

    var jsonFileName: String? {
      switch self {
      case .main: return "PamphletData"
      case .resource: return "PamphletSectionContentResource"
      case .guideSyntax: return "guide-syntax"
      case .guideFeatures: return "guide-features"
      case .guideSubject: return "guide-subject"
      case .swiftUI: return "lib-SwiftUI"
      case .combine: return "lib-Combine"
      case .concurrency: return "lib-Concurrency"
      default: return ""
      }
    }

    func loadData() async -> [PamphletSectionModel] {
      guard let fileName = jsonFileName else { return [] }
      return loadBundleJSONFile(fileName)
    }
  }

  struct CellModel {

    let sectionName: String
    let items: [SectionItemModel]
    let originModel: PamphletSectionModel

    static func convert(with model: PamphletSectionModel) -> CellModel {
      let items = model.displayItems.compactMap { item in
        switch model.type {
        case .issue:
          if let item = item as? PamphletSectionModel.PamphletIssueModel {
            return SectionItemModel(title: item.title, imageName: "", jumpUrl: "", issueNumber: item.number)
          }
        case .item:
          if let item = item as? PamphletSectionModel.PamphletSimpleModel {
            return SectionItemModel(title: item.title, imageName: item.imageName, jumpUrl: item.jumpUrl, issueNumber: 0)
          }
        }
        return nil
      }
      return CellModel(sectionName: model.sectionName, items: items, originModel: model)
    }
  }

  struct SectionItemModel {
    let title: String
    let imageName: String?
    let jumpUrl: String?
    let issueNumber: Int
  }
}

fileprivate extension Array where Element == PamphletViewController.CellModel {
  subscript(indexPath: IndexPath) -> PamphletViewController.SectionItemModel? {
    guard indexPath.section < self.count else { return nil }
    let sectionModel = self[indexPath.section]
    guard indexPath.row < sectionModel.items.count else { return nil }
    return sectionModel.items[indexPath.row]
  }
}
