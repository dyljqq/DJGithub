//
//  Feeds.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import UIKit

enum FeedPushType {
  case repo(String)
  case user(String)
  case unknown
}

enum FeedEventType: String {
  case Follow, Watch, Fork, Create, Release, Public, UnKnown
}

struct Feeds: DJCodable {
  var currentUserUrl: String
}

struct FeedInfo: DJCodable {
  var title: String
  var updated: String
  var entry: [Feed]
}

struct Feed: DJCodable {
  var id: String
  var published: String?
  var title: String?
  var content: String
  var author: FeedAuthor?
  var thumbnail: FeedAuthorThumbnail?
  var link: FeedLink?
  
  var formatedDate: String? {
    guard let published = published,
          let date = FeedDateParser.date(from: published)else {
      return published
    }
    let diff = (Date.now.timeIntervalSince1970 - date.timeIntervalSince1970)
    if diff < 60 {
      return "\(diff) seconds ago"
    } else if diff >= 60 && diff < 3600 {
      return "\(Int(diff / 60)) minuts ago"
    } else if diff >= 3600 && diff < 24 * 3600 {
      return "\(Int(diff / 3600)) hours ago"
    } else if diff >= 24 * 3600 && diff <= 24 * 30 * 3600 {
      return "\(Int(diff / (24 * 3600))) days ago"
    } else if diff >= (24 * 30 * 3600) && diff < (12 * 30 * 24 * 30 * 3600) {
      return "\(Int(diff / (30 * 24 * 3600))) months ago"
    } else {
      if let published = published.components(separatedBy: "T").first {
        return published
      }
    }
    return published
  }
  
  var eventName: String? {
    return RegularParser.parse(with: ":([a-zA-Z]+)Event", validateString: self.id).first
  }
  
  var eventType: FeedEventType {
    if let eventName = eventName, let type = FeedEventType(rawValue: eventName) {
      return type
    }
    return .UnKnown
  }
  
  enum CodingKeys: String, CodingKey {
    case id, published, title, content, author, thumbnail = "media:thumbnail", link
  }
}

struct FeedAuthor: DJCodable {
  var name: String
  var email: String?
  var uri: String?
}

struct FeedAuthorThumbnail: DJCodable {
  var url: String?
  var width: String?
  var height: String?
}

struct FeedLink: DJCodable {
  var type: String?
  var href: String?
  
  var path: String? {
    guard let href = href else { return nil }
    if var path = URLComponents(string: href)?.path {
      if path.starts(with: "/") {
        path.removeFirst()
      }
      return path
    }
    return nil
  }
}

extension Feed {
  var titleAttr: NSAttributedString? {
    guard let title = self.title, let userName = self.author?.name else { return nil }
    let attr = NSMutableAttributedString(string: title)
    var checkedTexts: [(String, String)] = [(userName, "User")]
    switch self.eventType {
    case .Watch, .Public:
      if let path = self.link?.path {
        checkedTexts.append((path, "Repo"))
      }
    case .Follow:
      if let path = self.link?.path {
        checkedTexts.append((path, "User"))
      }
    case .Fork:
      let arr = title.components(separatedBy: " ")
      if arr.count == 5 {
        checkedTexts.append(contentsOf: [
          (arr[2], "Repo"), (arr[4], "Repo")
        ])
      }
    case .Create, .Release:
      let arr = title.components(separatedBy: " ")
      let text = arr.last!
      checkedTexts.append((text, "Repo"))
    case .UnKnown:
      break
    }
    
    for (checked, type) in checkedTexts {
      if let match = RegularParser.matches(with: checked, validateString: title).first {
        let range = match.range(at: 0)
        attr.addAttribute(NSAttributedString.Key.link, value: "value=\(checked)&type=\(type)", range: range)
      }
    }
    attr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: title.count))
    return attr
  }
  
  var titleHeight: CGFloat {
    guard let title = title, let titleAttr = titleAttr else { return 0 }
    var range = NSRange(location: 0, length: title.count)
    let dict = titleAttr.attributes(at: 0, effectiveRange: &range)
    let height = (title as NSString).boundingRect(
      with: CGSize(width: FrameGuide.screenWidth - 64, height: 0),
      options: .usesLineFragmentOrigin,
      attributes: dict,
      context: nil
    ).height
    return height + 1
  }
}
