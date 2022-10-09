//
//  User.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct User: DJCodable {
  var login: String
  var name: String?
  var id: Int
  var bio: String?
  var avatarUrl: String
  var type: String
  var createdAt: String

  var followers: Int
  var following: Int
  var publicRepos: Int
  var reposUrl: String
  var followingUrl: String
  var followersUrl: String
  
  var company: String?
  var location: String?
  var email: String?
  var blog: String?
  
  var desc: String {
    return isEmpty(by: self.bio) ? "No description provided." : self.bio!
  }
}

struct UserContribution: DJCodable {
  var totalContributions: Int
  var colors: [String]
  var items: [UserContributionItem]
  
  init(with dict: [String: Any]) {
    totalContributions = dict["totalContributions"] as? Int ?? 0
    colors = dict["colors"] as? [String] ?? []
    guard let weeks = dict["weeks"] as? [[String: Any]] else {
      items = []
      return
    }
    
    items = []
    for week in weeks {
      if let days = week["contributionDays"] as? [[String: Any]] {
        for day in days {
          if let item = try? DJDecoder<UserContributionItem>(dict: day).decode() {
            items.append(item)
          }
        }
      }
    }
  }
}

struct UserContributionItem: DJCodable {
  var color: String
  var contributionCount: Int
  var date: String
  var weekday: Int
  
  var contributionDesc: String {
    let dateStr: String
    if let date = self.date.split(separator: "T").first {
      dateStr = String(describing: date)
    } else {
      dateStr = self.date
    }
    return "\(contributionCount) contributions on \(dateStr)"
  }
}
