//
//  PamphletSimpleModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import Foundation

struct PamphletSectionModel: DJCodable {

  enum PSType: DJCodable {
    case item
    case issue
  }

  struct PamphletSimpleModel: DJCodable {
    let imageName: String?
    let title: String
    let jumpUrl: String?
  }

  struct PamphletIssueModel: DJCodable {
    let id: Int
    let title: String
    let number: Int
  }

  var sectionName: String
  var items: [PamphletSimpleModel]?
  var issues: [PamphletIssueModel]?
  var type: PSType {
    if items != nil {
      return .item
    } else {
      return .issue
    }
  }

  var displayItems: [DJCodable] {
    if let items = items {
      return items
    } else if let issues = issues {
      return issues
    }
    return []
  }
}
