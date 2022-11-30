//
//  AppStyleMaskView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/30.
//

import UIKit

struct AppStyleUtility {

  static let shared = AppStyleUtility()

  let tag = 8888

  var coverViews: [UIView] = []

  func open(with style: AppStyle) {
    guard let window = UIApplication.shared.keyWindow else { return }
    blendAppStyle(with: style, for: window)
  }

  func close() {
    guard let window = UIApplication.shared.keyWindow else { return }
    for subview in window.subviews {
      if subview.tag == tag {
        subview.removeFromSuperview()
      }
    }
  }

  private func blendAppStyle(with style: AppStyle, for maskView: UIView) {
    guard #available(iOS 13.0, *), !hasBlended(with: maskView) else { return }

    let view = UIView(frame: maskView.bounds)
    view.isUserInteractionEnabled = false
    view.backgroundColor = style.color
    view.layer.compositingFilter = "saturationBlendMode"
    view.layer.zPosition = CGFloat.greatestFiniteMagnitude
    maskView.addSubview(view)
  }

  private func hasBlended(with maskView: UIView) -> Bool {
    for subView in maskView.subviews {
      if subView.tag == tag {
        return true
      }
    }
    return false
  }

}
