//
//  Parser.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

protocol Parsable {
  
  associatedtype DataType: DJCodable
  
  func parse(with data: Data?) async throws -> DataType?
}
