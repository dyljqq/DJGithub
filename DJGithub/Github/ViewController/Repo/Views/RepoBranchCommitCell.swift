//
//  RepoBranchCommitCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import UIKit

class RepoBranchCommitCell: UITableViewCell {

  lazy var commitView: RepoBranchCommitUserView = {
    let view = RepoBranchCommitUserView()
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(commitView)
    commitView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func render(with model: RepoBranchCommitInfo) {
    commitView.render(with: model)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
