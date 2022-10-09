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

class DJJSONParser<T: DJCodable>: JSONDecoder, Parsable {
  
  typealias DataType = T
  
  override init() {
    super.init()
    self.keyDecodingStrategy = .convertFromSnakeCase
  }
  
  func parse(with data: Data?) async throws -> T? {
    guard let data = data else { return nil }
    do {
      return try self.decode(T.self, from: data)
    } catch {
      throw DJError.parseError("\(error)")
    }
  }
}

class DJXMLParser<T: DJCodable>: NSObject, Parsable, XMLParserDelegate {
  
  typealias DataType = T

  var continuation: CheckedContinuation<T?, Error>?
  
  var currentEntry: [String: String] = [:]
  var currentElement: String = ""
  var dict: [String: Any] = [:]
  var isParseEntry: Bool = false

  func parse(with data: Data?) async throws -> T? {
    guard let data = data else { return nil }
    do {
      return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<T?, Error>) in
        self?.continuation = continuation
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
      }
    } catch {
      print("parse error: \(error)")
      return nil
    }
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == "entry" {
      currentEntry = [:]
      isParseEntry = true
    } else {
      dict[elementName] = ""
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let data = string.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)
    currentEntry[currentElement, default: ""] += data
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if !isParseEntry {
      dict = currentEntry
    } else if elementName == "entry" {
      if let items = dict["items"] as? [[String: String]] {
        dict["items"] = items + [currentEntry]
      } else {
        dict["items"] = [currentEntry]
      }
    }
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
    do {
      let model: T? = try DJDecoder(dict: dict).decode()
      self.continuation?.resume(returning: model)
    } catch {
      print("error: \(error)")
    }
  }
}
