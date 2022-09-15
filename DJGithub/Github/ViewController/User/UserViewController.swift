//
//  UserViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit
import SnapKit

class UserViewController: UIViewController {

  lazy var userHeaderView: UserHeaderView = {
    let view = UserHeaderView()
    view.frame = CGRect(x: 0, y: 0, width: FrameGuide.shared.screenWidth, height: 135)
    return view
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = userHeaderView
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = UIColorFromRGB(0xf5f5f5)
    return tableView
  }()
  
  var dataSource: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  func setUp() {
    view.backgroundColor = .white
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    Task {
      if let user = await UserViewModel.getUser(with: "dyljqq") {
        self.title = user.type
        userHeaderView.render(with: user)
      }
    }
  }

}

extension UserViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}

extension UserViewController: UITableViewDelegate {
  
}
