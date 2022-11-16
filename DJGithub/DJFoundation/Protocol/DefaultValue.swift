//
//  DefaultValue.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/2.
//

import Foundation

protocol DefaultValue {
  associatedtype Value: Codable
  static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
  var wrappedValue: T.Value
}

extension Default: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(T.Value.self) as? String, value.isEmpty {
      wrappedValue = T.defaultValue
    } else {
      wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
  }
}

extension Default: Encodable {
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}

extension KeyedDecodingContainer {
  func decode<T>(
    _ type: Default<T>.Type,
    forKey key: Key
  ) throws -> Default<T> where T: DefaultValue {
    try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
  }
}
