//
//  LanguageGradientView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/26.
//

import UIKit

class LanguageGradientView: UIView {

  private var percent: CGFloat = 0

  var primaryLanguageLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    return layer
  }()

  init() {
    super.init(frame: CGRect.zero)
    setUp()
  }

  private func setUp() {
    backgroundColor = UIColorFromRGB(0xeeeeee)
    self.layer.addSublayer(primaryLanguageLayer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func render(with primaryLanguage: PrimaryLanguage, language: Repository.RepositotyLanguage) {
    guard language.totalSize > 0 else { return }
    percent = language.primaryPercent(with: primaryLanguage.name)
    primaryLanguageLayer.backgroundColor = primaryLanguage.color.toColor?.cgColor
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    primaryLanguageLayer.frame = CGRect(x: 0, y: 0, width: percent * self.bounds.width, height: self.bounds.height)
  }

}
