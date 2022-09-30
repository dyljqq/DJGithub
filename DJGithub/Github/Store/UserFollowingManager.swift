//
//  UserFollowingManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/30.
//

import Foundation

enum UserFollowingStatus {
  case following
  case unfollow
  case unknown
}

actor UserFollowingHolder {
  var mapping = [String: UserFollowingStatus]()
  
  func batchUpdate(with users: [User]) {
    Task {
      for user in users {
        if let followingStatus = await UserManager.checkFollowStatus(with: user.login) {
          self.mapping[user.login] = followingStatus.isStatus204 ? .following : .unfollow
        }
      }
    }
  }
  
  func update(with userName: String) async -> UserFollowingStatus {
    let task = Task { () -> UserFollowingStatus in
      if let followingStatus = await UserManager.checkFollowStatus(with: userName) {
        let type: UserFollowingStatus = followingStatus.isStatus204 ? .following : .unfollow
        self.mapping[userName] = type
        return type
      }
      return .unknown
    }
    return await task.value
  }
  
  func update(with userName: String, following: Bool) {
    mapping[userName] = following ? .following : .unfollow
  }
  
  func batchUpdate(with dict: [String: Bool]) {
    for (key, value) in dict {
      mapping[key] = value ? .following : .unfollow
    }
  }
  
  func followingStatus(with userName: String) -> UserFollowingStatus {
    return mapping[userName, default: .unknown]
  }
}

struct UserFollowingManager {
  
  static let shared = UserFollowingManager()
  
  var holder = UserFollowingHolder()
  
  func update(with userName: String, following: Bool) async {
    await holder.update(with: userName, following: following)
  }
  
  func update(with user: User) async {
    await holder.batchUpdate(with: [user])
  }
  
  func batchUpdate(with users: [User]) async {
    await holder.batchUpdate(with: users)
  }
  
  func followingStatus(with userName: String) async -> UserFollowingStatus {
    return await holder.followingStatus(with: userName)
  }
  
  func update(with userName: String) async -> UserFollowingStatus {
    return await self.holder.update(with: userName)
  }
  
}
