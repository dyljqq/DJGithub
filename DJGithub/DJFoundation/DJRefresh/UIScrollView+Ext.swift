//
//  UIScrollView+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/18.
//

import UIKit

private var headerKey: UInt8 = 0
private var footerKey: UInt8 = 0

extension UIScrollView {
  
  private var dj_header: RefreshView? {
    get {
      return objc_getAssociatedObject(self, &headerKey) as? RefreshView
    }
    set {
      dj_header?.removeFromSuperview()
      objc_setAssociatedObject(self, &headerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      newValue.map { insertSubview($0, at: 0) }
    }
  }
  
  private var dj_footer: RefreshView? {
    get {
      return objc_getAssociatedObject(self, &footerKey) as? RefreshView
    }
    set {
      dj_footer?.removeFromSuperview()
      objc_setAssociatedObject(self, &footerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      newValue.map { insertSubview($0, at: 0) }
    }
  }
  
  public func addHeader(height: CGFloat = 60, action: @escaping () -> Void) {
    dj_header = IndicatorView(isHeader: true, height: height, action: action)
  }
  
  public func addFooter(height: CGFloat = 60, action: @escaping () -> Void) {
    dj_footer = IndicatorView(isHeader: false, height: height, action: action)
    dj_footer?.backgroundColor = .red
  }
  
  public func dj_beginRefresh() {
    dj_header?.beginRefreshing()
  }
  
  public func dj_endRefresh() {
    dj_header?.endRefreshing()
    dj_footer?.endRefreshing()
  }
  
}
