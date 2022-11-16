//
//  OrganizationViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/11.
//

import UIKit

class OrganizationViewController: UIViewController {

  private let name: String

  var organization: Organization?
  fileprivate var dataSource: [CellType] = []

  lazy var userHeaderView: UserHeaderView = {
    let view = UserHeaderView(frame: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 135))
    return view
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = userHeaderView
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .backgroundColor
    tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.className)
    tableView.register(UserCell.classForCoder(), forCellReuseIdentifier: UserCell.className)
    tableView.register(PinnedItemsCell.classForCoder(), forCellReuseIdentifier: PinnedItemsCell.className)
    return tableView
  }()

  init(with name: String) {
    self.name = name
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUp()
  }

  private func setUp() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    if let organization = organization {
      self.reload(with: organization)
    } else {
      Task {
        view.startLoading()
        let organization = await UserManager.fetchOrganizationInfo(by: name)
        self.organization = organization
        self.reload(with: organization)
        view.stopLoading()
      }
    }

    userHeaderView.renderHeightClosure = { [weak self] height in
      guard let strongSelf = self else { return }
      strongSelf.userHeaderView.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: height)
      strongSelf.tableView.beginUpdates()
      strongSelf.tableView.endUpdates()
    }
  }

  private func reload(with organization: Organization?) {
    guard let organization = organization else { return }
    self.userHeaderView.render(with: organization)

    dataSource = []
    if !organization.pinnedItems.nodes.isEmpty {
      dataSource.append(contentsOf: [.blank, .pinnedItems])
    }
    dataSource.append(.blank)
    dataSource.append(.user(.company))
    dataSource.append(.user(.location))
    dataSource.append(.user(.email))
    dataSource.append(.user(.link))
    tableView.reloadData()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

extension OrganizationViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = dataSource[indexPath.row]
    switch model {
    case .blank:
      let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
      cell.backgroundColor = .backgroundColor
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
      return cell
    case .pinnedItems:
      let cell = tableView.dequeueReusableCell(withIdentifier: PinnedItemsCell.className, for: indexPath) as! PinnedItemsCell
      if let organization {
        cell.render(with: organization.pinnedItems)
        cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        cell.onTouchPinnedItem = { [weak self] item in
          guard let strongSelf = self else { return }
          strongSelf.naviVc?.navigationController?.pushToRepo(with: strongSelf.name, repoName: item.name)
        }
      }
      return cell
    case .user(let userType):
      let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.className, for: indexPath) as! UserCell
      if userType.isShowAccessory {
        cell.accessoryType = .disclosureIndicator
      } else {
        cell.accessoryType = .none
      }
      let contentModel = userType.getContent(by: organization)
      cell.render(with: userType.iconImageName, content: contentModel.content, contentColor: contentModel.color)
      return cell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSource[indexPath.row].height
  }
}

extension OrganizationViewController {
  fileprivate enum CellType {
    case blank
    case pinnedItems
    case user(UserCellType)

    var height: CGFloat {
      switch self {
      case .blank: return 12
      case .pinnedItems: return 110
      case .user: return 44
      }
    }
  }
}
