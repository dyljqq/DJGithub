//
//  User.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct User: Decodable {
  var login: String
  var name: String
  var id: Int
  var bio: String
  var avatarUrl: String
  var type: String
  var createdAt: String

  var followers: Int
  var following: Int
  var publicRepos: Int
  var reposUrl: String
  var followingUrl: String
  var followersUrl: String
  
  var company: String
  var location: String
  var email: String?
  var blog: String
}
