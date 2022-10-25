//
//  String+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit
import CryptoKit

extension String {
  var toColor: UIColor? {
    let hexStr = self.first == "#" ? String(Array(self).dropFirst()) : self
    guard let v = UInt(hexStr, radix: 16) else {
      return nil
    }
    return UIColorFromRGB(v)
  }
  
  var md5: String {
    guard let data = data(using: .utf8) else { return self }
    let hashed = SHA256.hash(data: data)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  var splitRepoFullName: (String, String)? {
    let arr = self.components(separatedBy: "/")
    return arr.count == 2 ? (arr[0], arr[1]) : nil
  }
}
