//
//  UIColor+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import UIKit

extension UIColor {
  static var randomColor: UIColor? {
    return randomHex.toColor
  }

  static var randomHex: String {
    let red = arc4random() % 256
    let green = arc4random() % 256
    let blue = arc4random() % 256
    return String(red, radix: 16) + String(green, radix: 16) + String(blue, radix: 16)
  }
}
