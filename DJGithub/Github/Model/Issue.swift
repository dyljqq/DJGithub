//
//  Issue.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

struct IssueItems: DJCodable {
  var items: [Issue]
}

struct IssueLayout {
  let issue: Issue
  let title: String
  var height: CGFloat = 0
  var imageName: String = ""
  
  init(issue: Issue) {
    self.issue = issue
    self.title = "#\(self.issue.number) - \(self.issue.title)"
  }
  
  mutating func calHeight() {
    let rect = (self.title as NSString).boundingRect(with: CGSize(width: FrameGuide.screenWidth - 45, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    self.height = rect.height + 41
  }
}

struct Issue: DJCodable {
  enum IssueState: String, DJCodable {
    case open, closed
  }
  
  struct PullRequest: DJCodable {
    var url: String
    var htmlUrl: String
    var diffUrl: String
  }
  
  var id: Int
  var number: Int
  var title: String
  var state: IssueState
  var comments: Int?
  var htmlUrl:String

  var createdAt: String
  var updatedAt: String
  
  var user: UserFollowing?
  var pullRequest: PullRequest?
}
