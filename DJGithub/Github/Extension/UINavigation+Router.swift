//
//  UINavigation+Router.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension UINavigationController {

    func pushToUser(with name: String, type: UserContainerViewController.UserContainerType? = nil) {
        let vc = UserContainerViewController(name: name)
        vc.type = type
        self.pushViewController(vc, animated: true)
    }

    func pushToOrganization(with name: String) {
        let vc = OrganizationViewController(with: name)
        self.pushViewController(vc, animated: true)
    }

    func pushToUserContainer(with name: String, type: UserContainerViewController.UserContainerType? = nil) {
        let vc = UserContainerViewController(name: name)
        vc.type = type
        self.pushViewController(vc, animated: true)
    }

    func pushToUserStaredRepo(with userName: String) {
        let vc = UserStaredReposViewController(userRepoState: .star(userName))
        self.pushViewController(vc, animated: true)
    }

    func pushToRepo(with userName: String, repoName: String) {
        let vc = RepoViewController(with: userName, repoName: repoName)
        self.pushViewController(vc, animated: true)
    }

    func pushToWebView(with urlString: String? = nil, request: URLRequest? = nil) {
        let vc: WebViewController
        if let request = request {
            vc = WebViewController(with: request)
        } else {
            vc = WebViewController(with: urlString ?? "")
        }
        self.pushViewController(vc, animated: true)
    }

    func pushToRepoInteract(with repoName: String, selectedIndex: Int = 0) {
        let types: [RepoInteractViewController.RepoInteractType] = [
            .watches(repoName),
            .star(repoName),
            .forks(repoName),
            .contributor(repoName)
        ]
        let vc = RepoInteractViewController(with: types, title: repoName, selectedIndex: selectedIndex)
        self.pushViewController(vc, animated: true)
    }

    func pushToUserInteract(with userName: String, title: String, selectedIndex: Int = 0) {
        let types: [RepoInteractViewController.RepoInteractType] = [
            .repositories(userName),
            .followers(userName),
            .following(userName),
            .userStar(userName),
            .userWatches(userName)
        ]
        let vc = RepoInteractViewController(with: types, title: title, selectedIndex: selectedIndex)
        self.pushViewController(vc, animated: true)
    }

    func pushToRepoContent(with userName: String, repoName: String) {
        let vc = RepoContentsViewController(with: userName, repoName: repoName)
        self.pushViewController(vc, animated: true)
    }

    func pushToRepoContentFile(with urlString: String) {
        let vc = RepoContentFileViewController(with: urlString)
        self.pushViewController(vc, animated: true)
    }

    func pushToRepoIssues(
        with userName: String, repoName: String, issueState: RepoIssuesStateViewController.IssueState = .issue) {
            let vc = RepoIssuesStateViewController(userName: userName, repoName: repoName, issueState: issueState)
            self.pushViewController(vc, animated: true)
        }

    func pushToRepoIssue(with userName: String, repoName: String, issueNum: Int) {
        let vc = RepoIssueDetailViewController(userName: userName, repoName: repoName, issueNum: issueNum)
        self.pushViewController(vc, animated: true)
    }

    func pushToUserInfo() {
        let vc = UserInfoViewController()
        self.pushViewController(vc, animated: true)
    }

    func pushToUserInfoEdit(with type: UserInfoType, user: User?) {
        let vc = UserInfoEditViewController(with: type, user: user)
        pushViewController(vc, animated: true)
    }

    func pushToFeed(with feed: Feed) {
        let vc = FeedViewController(feed: feed)
        pushViewController(vc, animated: true)
    }

    func pushToRssFeeds(with atom: RssFeedAtom) {
        let vc = RssFeedsViewController(with: atom)
        pushViewController(vc, animated: true)
    }

    func pushToRssFeedDetial(with rssFeed: RssFeed) {
        let vc = RssFeedDetailViewController(rssFeed: rssFeed)
        pushViewController(vc, animated: true)
    }

    func pushToRepoBranchCommit(with base: String, head: String, urlString: String, showCommitButton: Bool = false) {
        let vc = RepoBranchCommitViewController(head: head, base: base, urlString: urlString)
        vc.showCommitButton = showCommitButton
        pushViewController(vc, animated: true)
    }

    func pushToRepoPull(with userName: String, repoName: String, pullNum: Int) {
        let vc = RepoPullRequestViewController(userName: userName, repoName: repoName, pullNum: pullNum)
        pushViewController(vc, animated: true)
    }

    func pushToSetting() {
        let vc = SettingViewController()
        pushViewController(vc, animated: true)
    }
}
