//
//  PrimaryLanguageCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/26.
//

import UIKit

fileprivate class LanguageSegView: UIView {
  lazy var circleView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 5
    return view
  }()
  
  lazy var languageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .textColor
    return label
  }()
  
  lazy var percentLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  init() {
    super.init(frame: .zero)
    
    setUp()
  }
  
  func render(with languageColor: UIColor?, languageName: String, percent: CGFloat) {
    circleView.backgroundColor = languageColor
    languageLabel.text = languageName
    percentLabel.text = "\(String(format: "%.2f", percent))%"
  }
  
  private func setUp() {
    addSubview(circleView)
    addSubview(languageLabel)
    addSubview(percentLabel)
    
    circleView.snp.makeConstraints { make in
      make.width.height.equalTo(10)
      make.leading.centerY.equalToSuperview()
    }
    languageLabel.snp.makeConstraints { make in
      make.leading.equalTo(circleView.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
    }
    percentLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(languageLabel.snp.trailing).offset(5)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class PrimaryLanguageCell: UITableViewCell {
  
  lazy var languageView: LanguageGradientView = {
    let view = LanguageGradientView()
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    return view
  }()

  fileprivate lazy var primaryLanguageView: LanguageSegView = {
    return LanguageSegView()
  }()
  
  fileprivate lazy var otherLanguageView: LanguageSegView = {
    return LanguageSegView()
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setUp()
  }
  
  func render(with primaryLanguage: PrimaryLanguage, language: Repository.RepositotyLanguage) {
    self.languageView.render(with: primaryLanguage, language: language)
    
    let percent = language.primaryPercent(with: primaryLanguage.name)
    primaryLanguageView.render(
      with: primaryLanguage.color.toColor,
      languageName: primaryLanguage.name,
      percent: percent
    )
    otherLanguageView.render(with: UIColorFromRGB(0xeeeeee), languageName: "Other", percent: 1 - percent)
  }
  
  private func setUp() {
    contentView.addSubview(languageView)
    contentView.addSubview(primaryLanguageView)
    contentView.addSubview(otherLanguageView)
    
    languageView.snp.makeConstraints { make in
      make.top.equalTo(10)
      make.leading.equalTo(12)
      make.centerX.equalToSuperview()
      make.height.equalTo(10)
    }
    primaryLanguageView.snp.makeConstraints { make in
      make.leading.equalTo(languageView)
      make.width.equalTo(languageView.snp.width).multipliedBy(0.33)
      make.height.equalTo(16)
      make.top.equalTo(languageView.snp.bottom).offset(10)
    }
    otherLanguageView.snp.makeConstraints { make in
      make.top.equalTo(primaryLanguageView)
      make.width.equalTo(languageView.snp.width).multipliedBy(0.33)
      make.height.equalTo(10)
      make.leading.equalTo(primaryLanguageView.snp.trailing)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
