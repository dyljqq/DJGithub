//
//  UIView+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/6.
//

import UIKit

extension UIView {
  
  var responseVC: UIViewController? {
    var next = self.next
    while let n = next {
      if let vc = n as? UIViewController {
        return vc
      }
      next = next?.next
    }
    return nil
  }
  
}
