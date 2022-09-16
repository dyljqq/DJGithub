//
//  RepoViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct RepoViewModel {
  static func fetchStaredRepos(with name: String) async -> Repos? {
    let router = GithubRouter.userStartedRepos(name)
    let result = await APIClient.shared.get(by: router)
    switch result {
    case .success(let d):
      return DJDecoder<Repos>(dict:d).decode()
    case .failure(let error):
      print("fetchStaredRepos: \(error)")
    }
    return nil
  }
}
