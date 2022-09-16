//
//  String+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension UIView {
  static var className: String {
    return String(describing: self.classForCoder())
  }
}
