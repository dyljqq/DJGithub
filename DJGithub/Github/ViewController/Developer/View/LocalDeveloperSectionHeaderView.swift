//
//  LocalDeveloperSectionHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/3.
//

import UIKit

class LocalDeveloperSectionHeaderView: UIView {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()

  init() {
    super.init(frame: .zero)
    self.backgroundColor = .backgroundColor
    addSubview(self.titleLabel)
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(16)
      make.centerY.equalTo(self)
    }
  }

  func render(with title: String) {
    self.titleLabel.text = title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
