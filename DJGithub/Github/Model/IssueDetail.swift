//
//  IssueDetail.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/5.
//

import Foundation

struct IssueDetail: DJCodable {

  var id: Int
  var number: Int
  var title: String
  var body: String?
  var createdAt: String
  var updatedAt: String
  var authorAssociation: String
  var htmlUrl: String
  var reactions: IssueDetailReaction?

  var state: Issue.IssueState

  var user: UserFollowing

}

struct IssueDetailReaction: DJCodable {
  var plus: Int
  var minus: Int
  var totalCount: Int

  enum CodingKeys: String, CodingKey {
    case plus = "+1", minus = "-1", totalCount
  }
}
