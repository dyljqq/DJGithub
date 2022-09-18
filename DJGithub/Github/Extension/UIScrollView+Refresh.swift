//
//  UIScrollView+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/18.
//

import UIKit

extension UIScrollView {
  var contentInsetTop: CGFloat {
    if #available(iOS 11.0, *) {
      return contentInset.top + adjustedContentInset.top
    } else {
      return contentInset.top
    }
  }

  var contentInsetBottom: CGFloat {
    if #available(iOS 11.0, *) {
      return contentInset.bottom + adjustedContentInset.bottom
    } else {
      return contentInset.bottom
    }
  }
}
