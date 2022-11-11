//
//  Organization.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/11.
//

import Foundation

struct Organization: DJCodable {
  let avatarUrl: String
  let createdAt: String
  let login: String

  @Default<String.UnProvidedDesc> var description: String
  @Default<String> var name: String
  @Default<String.Email> var email: String
  @Default<String.Location> var location: String
  @Default<String.Blog> var websiteUrl: String
  
  var membersWithRole: TotalCountModel
  var pinnableItems: TotalCountModel
  var pinnedItems: PinnedRepos
}
