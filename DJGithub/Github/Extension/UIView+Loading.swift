//
//  UIView+Loading.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

fileprivate let loadingTag = 8888

extension UIView {
  
  func startLoading(by size: CGSize = CGSize(width: 50, height: 50)) {
    let loadingView = LoadingView(with: size)
    loadingView.tag = loadingTag
    addSubview(loadingView)
    loadingView.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.size.equalTo(size)
    }
    loadingView.startAnimation()
  }
  
  func stopLoading() {
    guard let loadingView = self.viewWithTag(loadingTag) as? LoadingView else {
      return
    }
    loadingView.stopAnimation()
    loadingView.removeFromSuperview()
  }
  
}
