//
//  UserContributionCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserContributionCell: UITableViewCell {
  
  var userContributionView: UserContributionView = UserContributionView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with userContribution: UserContribution) {
    userContributionView.render(with: userContribution)
  }
  
  func setUp() {
    contentView.addSubview(userContributionView)
    userContributionView.snp.makeConstraints { make in
      make.edges.equalTo(self.contentView)
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
