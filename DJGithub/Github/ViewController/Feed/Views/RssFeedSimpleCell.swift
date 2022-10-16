//
//  RssFeedAtomCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedSimpleCell: UITableViewCell {
  
  struct RssFeedSimpleModel {
    let title: String
    let content: String
    let unread: Bool
    let readStr: String
    
    init(title: String, content: String, unread: Bool = true, readStr: String = "") {
      self.title = title
      self.content = content
      self.unread = unread
      self.readStr = readStr
    }
  }
  
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
  
  lazy var readStrLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textGrayColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with model: RssFeedSimpleModel) {
    titleLabel.text = model.title
    contentLabel.text = model.content
    
    if model.unread {
      titleLabel.textColor = .textColor
    } else {
      titleLabel.textColor = .textGrayColor
    }
    
    if model.readStr.isEmpty {
      readStrLabel.isHidden = true
    } else {
      readStrLabel.isHidden = false
      readStrLabel.text = model.readStr
    }
  }
  
  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(contentLabel)
    contentView.addSubview(readStrLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.top.equalTo(10)
      make.trailing.equalTo(readStrLabel.snp.leading).offset(-12)
    }
    contentLabel.snp.makeConstraints { make in
      make.leading.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.trailing.equalTo(-12)
    }
    readStrLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel)
      make.trailing.equalTo(-12)
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
