//
//  FeedCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import UIKit

class FeedCell: UITableViewCell {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUp() {
    
  }

}
