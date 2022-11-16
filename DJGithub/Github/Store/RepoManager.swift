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

  static func fetchRepository(with userName: String, repoName: String) async -> Repository? {
    let query = """
   query {\n      repository(owner: \"\(userName)\", name: \"\(repoName)\") {\n        url\n        homepageUrl\n        name\n        nameWithOwner\n        description\n        createdAt\n        updatedAt\n        pushedAt\n        isFork\n        isPrivate\n        viewerHasStarred\n        viewerSubscription\n        hasIssuesEnabled\n        forkCount\n        diskUsage\n        owner {\n          login\n          avatarUrl\n        }\n        parent {\n          name\n          owner {\n            login\n          }\n          nameWithOwner\n        }\n        primaryLanguage {\n          name\n          color\n        }\n        licenseInfo {\n          spdxId\n        }\n        stargazers {\n          totalCount\n        }\n        watchers {\n          totalCount\n        }\n        issues(states: OPEN) {\n          totalCount\n        }\n        pullRequests(states: OPEN) {\n          totalCount\n        }\n        refs(refPrefix: \"refs/heads/\") {\n          totalCount\n        }\n        releases {\n          totalCount\n        }\n        defaultBranchRef {\n          name\n          target {\n            ... on Commit {\n              history {\n                totalCount\n              }\n            }\n          }\n        }\n        languages(first: 30, orderBy: {field: SIZE, direction: DESC}) {\n          totalSize\n          edges {\n            node {\n              name\n              color\n            }\n            size\n          }\n        }\n      }\n    }
"""
    let router = GithubRouter.graphql(params: ["query": query])
    let data = try? await APIClient.shared.data(with: router)
    guard let data = data,
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let d = dict["data"] as? [String: Any],
          let repository = d["repository"] as? [String: Any] else {
      return nil
    }
    do {
      return try DJDecoder(dict: repository).decode()
    } catch {
      print("fetch repository error: \(error)")
    }
    return nil
  }

  static func fetchRepoBranches(with userName: String, repoName: String, params: [String: String]) async -> [RepoBranch] {
    let router = GithubRouter.branches(userName: userName, repoName: repoName, params: params)
    let brances: [RepoBranch]? = try? await APIClient.shared.model(with: router)
    return brances ?? []
  }

  static func fetchRepoBranchCommit(with urlString: String) async -> RepoBranchCommitInfo? {
    let info: RepoBranchCommitInfo? = try? await APIClient.shared.data(with: urlString)
    return info
  }

  static func createRepoPullRequest(with userName: String, repoName: String, params: [String: String]) async -> StatusModel? {
    let router = GithubRouter.createPullRequest(userName: userName, repoName: repoName, params: params)
    return try? await APIClient.shared.model(with: router)
  }

  static func getPullRequest(with userName: String, repoName: String, pullNum: Int) async -> RepoPull? {
    let router = GithubRouter.repoPull(userName: userName, repoName: repoName, pullNum: pullNum)
    return try? await APIClient.shared.model(with: router)
  }

  static func fetchRepoPullCommits(with userName: String, repoName: String, pullNum: Int) async -> [RepoBranchCommitInfo] {
    let router = GithubRouter.repoPullCommits(userName: userName, repoName: repoName, pullNum: pullNum)
    let infos: [RepoBranchCommitInfo]? = try? await APIClient.shared.model(with: router)
    return infos ?? []
  }

  static func fetchRepoPullFiles(with userName: String, repoName: String, pullNum: Int) async -> [RepoPullFile] {
    let router = GithubRouter.repoPullFiles(userName: userName, repoName: repoName, pullNum: pullNum)
    let files: [RepoPullFile]? = try? await APIClient.shared.model(with: router)
    return files ?? []
  }

  static func repoCanMerge(with userName: String, repoName: String, pullNum: Int) async -> Bool {
    let router = GithubRouter.repoBranchCanMerge(userName: userName, repoName: repoName, pullNum: pullNum)
    let status: StatusModel? = try? await APIClient.shared.model(with: router)
    if let status = status {
      return status.isStatus404
    }
    return false
  }

  static func mergePullRequest(with userName: String, repoName: String, pullNum: Int, params: [String: String]) async -> RepoPullMerge? {
    let router = GithubRouter.repoBranchMerge(userName: userName, repoName: repoName, pullNum: pullNum, params: params)
    return try? await APIClient.shared.model(with: router)
  }
}
