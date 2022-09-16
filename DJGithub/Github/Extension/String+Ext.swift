//
//  String+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension String {
  var toColor: UIColor? {
    guard self.first == "#" else {
      return nil
    }
    guard let v = UInt(String(Array(self).dropFirst()), radix: 16) else {
      return nil
    }
    return UIColorFromRGB(v)
  }
}
