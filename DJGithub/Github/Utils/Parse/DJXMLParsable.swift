//
//  DJXMLParsable.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

class XMLNode {
  var key: String = ""
  var value: String = ""
  var isEnd = false
  var isRoot = false
  var attributeDict: [String: String] = [:]
  var nodes: [XMLNode] = []

  var dict: [String: Any] = [:]

  init(with key: String) {
    self.key = key
  }

  func parseNodes() {
    for node in nodes {
      if node.nodes.isEmpty {
        if node.value.isEmpty {
          if !node.attributeDict.isEmpty {
            dict[node.key] = node.attributeDict
          } else {
            dict[node.key] = ""
          }
        } else {
          dict[node.key] = node.value
        }
      } else {
        node.parseNodes()
        if let value = dict[node.key] {
          if let items = value as? [[String: Any]] {
            dict[node.key] = items + [node.dict]
          } else {
            dict[node.key] = [value, node.dict]
          }
        } else {
          dict[node.key] = node.dict
        }
      }
    }
  }
}

class DJXMLParser<T: DJCodable>: NSObject, Parsable, XMLParserDelegate {
  typealias DataType = T

  var continuation: CheckedContinuation<T?, Error>?

  var dict: [String: Any] = [:]
  var currentElement: String = ""
  var currentValue: String = ""
  var rootNode: XMLNode?

  var nodes: [XMLNode] = []
  var stack: [XMLNode] = []

  func parse(with data: Data?) async throws -> T? {
    do {
      return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<T?, Error>) in
        guard let data = data, let strongSelf = self else { return }
        strongSelf.continuation = continuation
        let parser = XMLParser(data: data)
        parser.delegate = strongSelf
        parser.parse()
      }
    } catch {
      print("parse error: \(error)")
      return nil
    }
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
    let node = XMLNode(with: elementName)
    if stack.isEmpty {
      node.isRoot = true
    }
    if !attributeDict.isEmpty {
      node.attributeDict = attributeDict
    }
    stack.append(node)
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let data = string.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)
    if let topNode = stack.last {
      topNode.value = topNode.value + data
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let topNode = stack.last, topNode.key == elementName {
      let node = stack.removeLast()
      node.isEnd = true
      if node.isRoot {
        rootNode = node
      }
      if let parentNode = stack.last {
        parentNode.nodes.append(node)
      }
    }
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    rootNode?.parseNodes()
    guard var dict = rootNode?.dict else { return }
    /**
    目前已知的xml格式如下：
     format 1:
     <Feed>
            <channel>
                        // data
            </channel>
     </Feed>
     
     format 2:
     <Feed>
      // data
     </Feed>
     */
    if let channel = dict["channel"] as? [String: Any] {
      dict = channel
    }
    do {
      let model = try DJDecoder(dict: dict).decode() as T?
      continuation?.resume(returning: model)
    } catch {
      print("json parse error: \(error)")
      continuation?.resume(returning: nil)
    }
  }
}
