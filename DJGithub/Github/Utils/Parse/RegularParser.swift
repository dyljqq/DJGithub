//
//  RegularParser.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct RegularParser {
  static func parse(with pattern: String, validateString: String) -> [String] {
    do {
      let expression = try NSRegularExpression(pattern: pattern)
      let matches = expression.matches(in: validateString, range: NSRange(location: 0, length: validateString.count))
      return matches.compactMap { (validateString as NSString).substring(with: $0.range(at: 1)) }
    } catch {
      print("regular parse error: \(error)")
    }
    return []
  }
  
  static func matches(with pattern: String, validateString: String) -> [NSTextCheckingResult] {
    do {
      let expression = try NSRegularExpression(pattern: pattern)
      return expression.matches(in: validateString, range: NSRange(location: 0, length: validateString.count))
    } catch {
      return []
    }
  }
}
