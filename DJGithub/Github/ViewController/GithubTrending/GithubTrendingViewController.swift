//
//  GithubTrendingViewController.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import UIKit

class GithubTrendingViewController: UIViewController {

    private let manager = GithubTrendingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    private func setUp() {
        navigationItem.title = "Repos Trending"
        view.backgroundColor = .white
        
        let path = "/swift?since=daily"
        let vc = manager.addTrendingView(
            with: [.repo(path), .developer(path)],
            repoSelectedClosure: { [weak self] repo in
                self?.navigationController?.pushToRepo(with: repo.userName, repoName: repo.repoName)
            },
            developerSelectedClosure: { [weak self] developer in
                self?.navigationController?.pushToUser(with: developer.login)
            }
        )
        view.addSubview(vc.view)
        vc.view.backgroundColor = .white
        vc.view.snp.makeConstraints { make in
            make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}
