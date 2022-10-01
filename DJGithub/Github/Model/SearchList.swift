//
//  SearchList.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import Foundation

enum SearchType {
  case users
  case repos
  
  var title: String {
    switch self {
    case .users: return "users"
    case .repos: return "repos"
    }
  }
}

struct SearchList<T: Decodable>: Decodable {
  var totalCount: Int
  var incompleteResults: Bool
  var items: [T]
}
