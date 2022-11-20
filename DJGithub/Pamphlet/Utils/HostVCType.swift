//
//  HostVC.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

enum VCTransition {
  case push
  case present
}

enum HostVCType: String {
  case pamphlet
  case rssfeeds

  func getVC(with params: [String: String] = [:]) -> UIViewController? {
    switch self {
    case .pamphlet:
      if let type = params["type"] {
        return configPamphletVC(with: type)
      }
    case .rssfeeds:
      return configRssFeed()
    }
    return nil
  }
}

extension HostVCType {
  fileprivate func configPamphletVC(with typeName: String) -> PamphletViewController? {
    guard let type = PamphletViewController.VCType(rawValue: typeName) else { return nil }
    return PamphletViewController(type: type)
  }

  fileprivate func configRssFeed() -> RssFeedAtomViewController? {
    return RssFeedAtomViewController()
  }
}
