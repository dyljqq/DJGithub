//
//  GithubRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum GithubRouter: Router {

  case userInfo(String)
  case userInfoEdit(params: [String: String])
  case userContribution(parameters: [String: Any])
  case userStartedRepos(path: String, queryItems: [String: String])
  case repo(String)
  case userStaredRepo(String)
  case repoReadme(String)
  case starRepo(String)
  case unStarRepo(String)
  case userFollowing(String, queryItems: [String: String])
  case followUser(String)
  case unfollowUser(String)
  case checkFollowStatus(String)
  case stargazers(String, [String: String])
  case contributors(String, [String: String])
  case subscribers(String, [String: String])
  case forks(String, [String: String])
  case userRepos(String, [String: String])
  case userFollowers(String, [String: String])
  case userSubscription(String, [String: String])

  // search
  case searchUser([String: String])
  case searchRepos([String: String])

  // repo
  case repoContents(userName: String, repoName: String)
  case branches(userName: String, repoName: String, params: [String: String])
  case createPullRequest(userName: String, repoName: String, params: [String: String])
  case repoPullCommits(userName: String, repoName: String, pullNum: Int)
  case repoPullFiles(userName: String, repoName: String, pullNum: Int)

  // repo issues
  case repoIssues(userName: String, repoName: String, params: [String: String])
  case repoIssue(userName: String, repoName: String, issueNum: Int)
  case repoIssueCommit(userName: String, repoName: String, params: [String: String])
  case repoIssueUpdate(userName: String, repoName: String, issueNum: Int, params: [String: String])
  case repoIssueCommentCommit(userName: String, repoName: String, issueNum: Int, params: [String: String])
  case repoPullIssues(userName: String, repoName: String, params: [String: String])
  case repoPull(userName: String, repoName: String, pullNum: Int)
  case repoBranchCanMerge(userName: String, repoName: String, pullNum: Int)
  case repoBranchMerge(userName: String, repoName: String, pullNum: Int, params: [String: String])

  // Feed
  case feeds

  // graph
  case graphql(params: [String: String])

  var baseURLString: String {
    return "https://api.github.com/"
  }

  var method: HTTPMethod {
    switch self {
    case .userContribution: return .POST
    case .starRepo: return .PUT
    case .unStarRepo: return .DELETE
    case .followUser: return .PUT
    case .unfollowUser: return .DELETE
    case .repoIssueCommit: return .POST
    case .repoIssueUpdate: return .PATCH
    case .repoIssueCommentCommit: return .POST
    case .userInfoEdit: return .PATCH
    case .graphql: return .POST
    case .createPullRequest: return .POST
    case .repoBranchMerge: return .PUT
    default: return .GET
    }
  }

  var path: String {
    switch self {
    case .userInfo(let name): return "users/\(name)"
    case .userContribution: return "graphql"
    case .userStartedRepos(let name, _): return "users/\(name)/starred"
    case .repo(let name): return "repos/\(name)"
    case .userStaredRepo(let name): return "user/starred/\(name)"
    case .repoReadme(let name): return "repos/\(name)/readme"
    case .starRepo(let name): return "user/starred/\(name)"
    case .unStarRepo(let name): return "user/starred/\(name)"
    case .userFollowing(let name, _): return "users/\(name)/following"
    case .followUser(let name): return "user/following/\(name)"
    case .unfollowUser(let name): return "user/following/\(name)"
    case .checkFollowStatus(let name): return "user/following/\(name)"
    case .stargazers(let name, _): return "repos/\(name)/stargazers"
    case .subscribers(let name, _): return "repos/\(name)/subscribers"
    case .contributors(let name, _): return "repos/\(name)/contributors"
    case .forks(let name, _): return "repos/\(name)/forks"
    case .userRepos(let name, _): return "users/\(name)/repos"
    case .userFollowers(let name, _): return "users/\(name)/followers"
    case .userSubscription(let name, _): return "users/\(name)/subscriptions"
    case .searchUser: return "search/users"
    case .searchRepos: return "search/repositories"
    case .repoContents(let userName, let repoName): return "repos/\(userName)/\(repoName)/contents"
    case .repoIssues(let userName, let repoName, _): return "repos/\(userName)/\(repoName)/issues"
    case .repoIssue(let userName, let repoName, let issueNum): return "repos/\(userName)/\(repoName)/issues/\(issueNum)"
    case .repoIssueCommit(let userName, let repoName, _): return "repos/\(userName)/\(repoName)/issues"
    case .repoIssueUpdate(let userName, let repoName, let issueNum, _): return "repos/\(userName)/\(repoName)/issues/\(issueNum)"
    case .repoIssueCommentCommit(let userName, let repoName, let issueNum, _): return "repos/\(userName)/\(repoName)/issues/\(issueNum)/comments"
    case .userInfoEdit: return "user"
    case .feeds: return "feeds"
    case .repoPullIssues(let userName, let repoName, _): return "repos/\(userName)/\(repoName)/pulls"
    case .graphql: return "graphql"
    case .branches(let userName, let repoName, _): return "repos/\(userName)/\(repoName)/branches"
    case .createPullRequest(let userName, let repoName, _): return "repos/\(userName)/\(repoName)/pulls"
    case .repoPull(let userName, let repoName, let pullNum): return "repos/\(userName)/\(repoName)/pulls/\(pullNum)"
    case .repoPullCommits(let userName, let repoName, let pullNum): return "repos/\(userName)/\(repoName)/pulls/\(pullNum)/commits"
    case .repoPullFiles(let userName, let repoName, let pullNum): return "repos/\(userName)/\(repoName)/pulls/\(pullNum)/files"
    case .repoBranchCanMerge(let userName, let repoName, let pullNum): return "repos/\(userName)/\(repoName)/pulls/\(pullNum)/merge"
    case .repoBranchMerge(let userName, let repoName, let pullNum, _): return "repos/\(userName)/\(repoName)/pulls/\(pullNum)/merge"
    }
  }

  var headers: [String: String] {
    return [
      "Accept": "application/vnd.github+json"
    ]
  }

  var parameters: [String: Any] {
    switch self {
    case .userContribution(let params):
      return params
    case .graphql(let params):
      return params
    case .userStartedRepos(_, let queryItems):
      return queryItems
    case .repoIssueCommit(_, _, let params):
      return params
    case .repoIssueUpdate(_, _, _, let params):
      return params
    case .repoIssueCommentCommit(_, _, _, let params):
      return params
    case .createPullRequest(_, _, let params):
      return params
    case .repoBranchMerge(_, _, _, let params):
      return params
    case .userInfoEdit(let params):
      return params
    default: return [:]
    }
  }

  func asURLRequest() -> URLRequest? {
    var queryItems: [String: String] = [:]

    switch self {
    case .userStartedRepos(_, let items),
        .userFollowing(_, let items),
        .contributors(_, let items),
        .subscribers(_, let items),
        .stargazers(_, let items),
        .userRepos(_, let items),
        .userFollowers(_, let items),
        .userSubscription(_, let items),
        .searchRepos(let items),
        .searchUser(let items),
        .repoIssues(_, _, let items),
        .userInfoEdit(let items),
        .repoPullIssues(_, _, let items),
        .branches(_, _, let items),
        .forks(_, let items):
      queryItems = items
    case .repoPullFiles,
        .repoPullCommits:
      queryItems = ["per_page": "100"]
    default:
      break
    }
    var request = configURLRequest(with: queryItems)
    request?.setValue(DJUserDefaults.accessToken(), forHTTPHeaderField: "Authorization")
    if !parameters.isEmpty {
      switch method {
      case .POST, .PATCH: request?.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
      default: break
      }
    }
    return request
  }
}
