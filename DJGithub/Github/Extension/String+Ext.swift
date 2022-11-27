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

extension String {
  func boundingRect(with size: CGSize,
                    options: NSStringDrawingOptions = [],
                    attributes: [NSAttributedString.Key: Any]? = nil,
                    context: NSStringDrawingContext?,
                    completionHandler: @escaping (CGRect) -> Void) {
    DispatchQueue.global(qos: .utility).async {
      let rect = (self as NSString).boundingRect(
        with: size,
        options: options,
        attributes: attributes,
        context: context)
      DispatchQueue.main.async {
        completionHandler(rect)
      }
    }
  }

  func asyncBoundingRect(with size: CGSize,
                    options: NSStringDrawingOptions = [],
                    attributes: [NSAttributedString.Key: Any]? = nil,
                         context: NSStringDrawingContext?) async -> CGRect? {
    try? await withCheckedThrowingContinuation { continuation in
      self.boundingRect(
        with: size,
        options: options,
        attributes: attributes,
        context: context
      ) { rect in
        continuation.resume(returning: rect)
      }
    }
  }
}
