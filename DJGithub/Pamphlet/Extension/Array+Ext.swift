//
//  Array+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

extension Array where Element == PamphletSectionModel {
  subscript(indexPath: IndexPath) -> PamphletSectionModel.PamphletSimpleModel? {
    guard indexPath.section < self.count else { return nil }
    let sectionModel = self[indexPath.section]
    guard indexPath.row < sectionModel.items.count else { return nil }
    return sectionModel.items[indexPath.row]
  }
}
