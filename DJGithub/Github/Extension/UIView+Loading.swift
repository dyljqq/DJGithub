//
//  UIView+Loading.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

fileprivate let loadingTag = 8888
private var loadingKey = 0

extension UIView {
  
  func startLoading(by size: CGSize = CGSize(width: 50, height: 50)) {
    let loadingView = LoadingView(with: size)
    loadingView.backgroundColor = .white
    addSubview(loadingView)

    loadingView.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.size.equalTo(self.bounds.size)
    }
    loadingView.startAnimation()
    objc_setAssociatedObject(self, &loadingKey, loadingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
  
  func stopLoading() {
    guard let loadingView = objc_getAssociatedObject(self, &loadingKey) as? LoadingView else {
      return
    }
    loadingView.stopAnimation()
    loadingView.removeFromSuperview()
  }
  
}
