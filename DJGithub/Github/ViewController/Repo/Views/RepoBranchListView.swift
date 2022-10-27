//
//  RepoBranchListView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import UIKit

class RepoBranchListView: UIView {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Branch"
    label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    label.textColor = .textColor
    return label
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .white
    tableView.showsVerticalScrollIndicator = false
    tableView.rowHeight = 30
    tableView.separatorColor = UIColorFromRGB(0xeeeeee)
    tableView.register(RepoBranchCell.classForCoder(), forCellReuseIdentifier: RepoBranchCell.className)
    return tableView
  }()
  
  var selectedClosure: ((RepoBranch) -> ())?
  
  var defaultBranchName: String = ""
  var branches: [RepoBranch] = []
  
  init() {
    super.init(frame: .zero)
    
    setUp()
  }
  
  func render(with branches: [RepoBranch], defaultBranchName: String = "master") {
    self.defaultBranchName = defaultBranchName
    self.branches = branches
    self.tableView.reloadData()
  }
  
  private func setUp() {
    backgroundColor = .white
    
    addSubview(titleLabel)
    addSubview(tableView)
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(12)
      make.centerX.equalToSuperview()
    }
    tableView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension RepoBranchListView: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return branches.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RepoBranchCell.className, for: indexPath) as! RepoBranchCell
    let branch = branches[indexPath.row]
    cell.render(with: branch, selected: branch.name == defaultBranchName)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    selectedClosure?(branches[indexPath.row])
  }
}
