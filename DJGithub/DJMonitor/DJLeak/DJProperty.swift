//
//  DJProperty.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import Foundation

struct DJProperty {
  
  fileprivate let property: objc_property_t
  
  var isStrong: Bool {
    guard let at = property_getAttributes(property) else { return false }
    let attr = String(cString: at)
    return attr.contains("&")
  }
  
  var name: String {
    let name = property_getName(property)
    return String(cString: name)
  }
  
  var type: AnyClass? {
    guard let attr = property_getAttributes(property),
          let t = String(cString: attr).components(separatedBy: ",").first,
          let type = t.between("@\"", "\"") else { return nil }
    return NSClassFromString(type)
  }
  
  init(with property: objc_property_t) {
    self.property = property
  }
  
}

extension String {
  public func between(_ left: String, _ right: String) -> String? {
      guard let leftRange = range(of:left),
          let rightRange = self.range(of: right, options: String.CompareOptions.backwards, range: nil, locale: nil),
          left != right && leftRange.upperBound != rightRange.lowerBound
          else { return nil }
      return String(self[leftRange.upperBound..<rightRange.lowerBound])
      
  }
}
