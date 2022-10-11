//
//  RssFeedAtomCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedAtomCell: UITableViewCell {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 0
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with title: String, des: String) {
    titleLabel.text = title
    contentLabel.text = des.isEmpty ? "No Description Provided." : des
  }
  
  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(contentLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.top.equalTo(10)
    }
    contentLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
  }
  
  static func cellHeight(by title: String, content: String) -> CGFloat {
    let titleHeight = (title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)],
      context: nil).height
    let contentHeight = (content as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 24, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
      context: nil).height
    return titleHeight + contentHeight + 27
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
