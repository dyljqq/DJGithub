//
//  HomeViewController.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {

    var feedItemSelectedClosure: (RssFeedLatestCellModel) -> Void {
        return { [weak self] feed in
            if let feed = RssFeed.get(by: feed.feedId) as RssFeed? {
              Task {
                await feed.updateReadStatus()
                NotificationCenter.default.post(name: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: ["atomId": feed.atomId])
              }
              self?.navigationController?.pushToRssFeedDetial(with: feed)
            }
        }
    }

    var repoSelectedClosure: (GithubTrendingRepo) -> Void {
        return { [weak self] repo in
            self?.navigationController?.pushToRepo(with: repo.userName, repoName: repo.repoName)
        }
    }

    var developerSelectedClosure: (GithubTrendingDeveloper) -> Void {
        return { [weak self] developer in
            self?.navigationController?.pushToUser(with: developer.login)
        }
    }

    var pamphletItemSelectedClosure: ((PamphletSectionModel.PamphletSimpleModel) -> Void) {
        return { pamphlet in
            URLRouter.open(with: pamphlet.jumpUrl)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    private func setUp() {
        navigationItem.title = "Home"

        let home = Home(
            feedItemSelectedClosure: feedItemSelectedClosure,
            repoSelectedClosure: repoSelectedClosure,
            developerSelectedClosure: developerSelectedClosure,
            pamphletItemSelectedClosure: pamphletItemSelectedClosure
        )
        let homeV = UIHostingController(rootView: home)
        view.addSubview(homeV.view)
        homeV.view.snp.makeConstraints { make in
            make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
            make.bottom.equalTo(-FrameGuide.tabbarHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
}
