//
//  GithubTrendingRepoViewController.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import UIKit

class GithubTrendingRepoViewController: UIViewController {
    
    private let manager = GithubTrendingManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    private func setUp() {
        navigationItem.title = "Repos Trending"
        view.backgroundColor = .white
        
        let vc = manager.addTrendingRepoView(with: "/swift?since=daily") { [weak self] userName, repoName in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushToRepo(with: userName, repoName: repoName)
        }
        view.addSubview(vc.view)
        vc.view.backgroundColor = .white
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
