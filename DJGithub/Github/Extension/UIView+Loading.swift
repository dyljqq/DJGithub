//
//  UIView+Loading.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

private let loadingTag = 8888
private var loadingKey = 0

extension UIView {

 private var _loadingView: LoadingView? {
    get {
      return objc_getAssociatedObject(self, &loadingKey) as? LoadingView
    }
    set {
      objc_setAssociatedObject(self, &loadingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func startLoading(by size: CGSize = CGSize(width: 50, height: 50)) {
    if let loadingView = _loadingView {
      loadingView.startAnimation()
      return
    }

    let loadingView = LoadingView(with: size)
    loadingView.backgroundColor = .white
    addSubview(loadingView)

    loadingView.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.size.equalTo(self.bounds.size)
    }
    loadingView.startAnimation()
    self._loadingView = loadingView
  }

  func stopLoading() {
    guard let loadingView = self._loadingView else { return }
    loadingView.stopAnimation()
    loadingView.removeFromSuperview()
    objc_removeAssociatedObjects(loadingView)
  }

}
