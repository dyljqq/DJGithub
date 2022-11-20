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
  case explore
  case archive
  case github
  case web
  case unknown

  func getVC(with params: [String: String] = [:]) -> UIViewController? {
    switch self {
    case .pamphlet:
      if let type = params["type"] {
        return configPamphletVC(with: type)
      }
    case .rssfeeds:
      return configRssFeed()
    case .explore:
      if let filename = params["filename"],
       let title = params["title"] {
        return configExploreVC(with: filename, title: title)
      }
    case .archive:
      if let filename = params["filename"],
         let title = params["title"] {
        return configArchiveVC(with: filename, title: title)
      }
    case .github:
      if let userName = params["userName"],
         let repoName = params["repoName"] {
        return configRepoVC(with: userName, repoName: repoName)
      }
    case .web:
      if let urlString = params["url"] {
        return configWebVC(with: urlString)
      }
    case .unknown:
      return nil
    }
    return nil
  }
}

fileprivate extension HostVCType {
  func configPamphletVC(with typeName: String) -> PamphletViewController? {
    guard let type = PamphletViewController.VCType(rawValue: typeName) else { return nil }
    return PamphletViewController(type: type)
  }

  func configRssFeed() -> RssFeedAtomViewController? {
    return RssFeedAtomViewController()
  }

  func configExploreVC(with filename: String, title: String) -> LocalDevelopersViewController? {
    return LocalDevelopersViewController(with: .repo, filename: filename, title: title)
  }

  func configArchiveVC(with filename: String, title: String) -> LocalDevelopersViewController? {
    return LocalDevelopersViewController(with: .repo, filename: filename, title: title)
  }

  func configRepoVC(with userName: String, repoName: String) -> RepoViewController? {
    let vc = RepoViewController(with: userName, repoName: repoName)
    return vc
  }

  func configWebVC(with urlString: String) -> WebViewController? {
    let vc = WebViewController(with: urlString)
    return vc
  }
}
