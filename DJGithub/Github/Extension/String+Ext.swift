//
//  String+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension String {
  var toColor: UIColor? {
    let hexStr = self.first == "#" ? String(Array(self).dropFirst()) : self
    guard let v = UInt(hexStr, radix: 16) else {
      return nil
    }
    return UIColorFromRGB(v)
  }
}
