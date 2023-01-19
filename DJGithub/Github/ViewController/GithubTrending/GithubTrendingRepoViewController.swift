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
        view.backgroundColor = .white
        
        let vc = manager.addTrendingRepoView(with: "/swift?since=daily")
        view.addSubview(vc.view)
        vc.view.backgroundColor = .white
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
