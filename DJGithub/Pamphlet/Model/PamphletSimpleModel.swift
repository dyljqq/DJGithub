//
//  PamphletSimpleModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import Foundation

struct PamphletSectionModel: DJCodable {
  struct PamphletSimpleModel: DJCodable {
    let imageName: String?
    let title: String
    let jumpUrl: String?
  }

  var sectionName: String
  var items: [PamphletSimpleModel]
}
