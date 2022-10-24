//
//  RepoManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct RepoManager {
  
  static func fetchStaredRepos(with name: String, page: Int) async -> [Repo] {
    let router = GithubRouter.userStartedRepos(path: name, queryItems: ["page": "\(page)"])
    return (try? await APIClient.shared.model(with: router)) ?? []
  }
  
  static func fetchForkRepos(with name: String, page: Int) async ->[Repo] {
    let router = GithubRouter.forks(name, ["page": "\(page)"])
    return (try? await APIClient.shared.model(with: router)) ?? []
  }
  
  static func fetchUserRepos(with userName: String, page: Int) async -> [Repo] {
    let router = GithubRouter.userRepos(userName, ["page": "\(page)"])
    return (try? await APIClient.shared.model(with: router)) ?? []
  }
  
  static func fetchRepo(with name: String) async -> Repo? {
    let router = GithubRouter.repo(name)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func userStaredRepo(with name: String) async -> StatusModel? {
    let router = GithubRouter.userStaredRepo(name)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func fetchREADME(with repoName: String) async -> Readme? {
    let router = GithubRouter.repoReadme(repoName)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func starRepo(with repoName: String) async -> StatusModel? {
    let router = GithubRouter.starRepo(repoName)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func unStarRepo(with repoName: String) async -> StatusModel? {
    let router = GithubRouter.unStarRepo(repoName)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func getRepoContent(with userName: String, repoName: String) async -> [RepoContent] {
    let router = GithubRouter.repoContents(userName: userName, repoName: repoName)
    let repos = try? await APIClient.shared.model(with: router) as [RepoContent]?
    return repos ?? []
  }
  
  static func getRepoContent(with urlString: String) async -> [RepoContent] {
    return (try? await APIClient.shared.data(with: urlString)) ?? []
  }
  
  static func getRepoContentFile(with urlString: String) async -> RepoContent? {
    return try? await APIClient.shared.data(with: urlString)
  }
  
  static func getRepoIssues(with userName: String, repoName: String, params: [String: String]) async -> [Issue] {
    let router = GithubRouter.repoIssues(userName: userName, repoName: repoName, params: params)
    return (try? await APIClient.shared.model(with: router)) ?? []
  }
  
  static func getRepoPullIssues(with userName: String, repoName: String, params: [String: String]) async -> [Issue] {
    let router = GithubRouter.repoPullIssues(userName: userName, repoName: repoName, params: params)
    return (try? await APIClient.shared.model(with: router)) ?? []
  }
  
  static func getRepoIssueDetail(with userName: String, repoName: String, issueNum: Int) async -> IssueDetail? {
    let router = GithubRouter.repoIssue(userName: userName, repoName: repoName, issueNum: issueNum)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func createNewIssue(with userName: String, repoName: String, params: [String: String]) async -> StatusModel? {
    let router = GithubRouter.repoIssueCommit(userName: userName, repoName: repoName, params: params)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func updateIssue(with userName: String, repoName: String, issueNum: Int, params: [String: String]) async -> IssueDetail? {
    let router = GithubRouter.repoIssueUpdate(userName: userName, repoName: repoName, issueNum: issueNum, params: params)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func createIssueComment(with userName: String, repoName: String, issueNum: Int, params: [String: String]) async -> StatusModel? {
    let router = GithubRouter.repoIssueCommentCommit(userName: userName, repoName: repoName, issueNum: issueNum, params: params)
    return try? await APIClient.shared.model(with: router)
  }
}
