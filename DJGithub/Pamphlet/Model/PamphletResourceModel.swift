//
//  PamphletResourceModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import Foundation

struct PamphletResourceModel: DJCodable {
  let title: String
  @Default<String.UnProvidedDesc> var desc: String
  let url: String

  enum CodingKeys: String, CodingKey {
    case title = "t"
    case url = "id"
    case desc = "d"
  }
}
