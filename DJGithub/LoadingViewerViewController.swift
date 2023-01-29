//
//  ViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

class LoadingViewerViewController: UIViewController {

    private let manager = AuthorizationViewManager()

    lazy var authorizationViewController: UIViewController = {
        return manager.addAuthorizationView { [weak self] isSucess in
            guard let strongSelf = self else { return }
            strongSelf.loadData(isSucess)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor

        view.addSubview(authorizationViewController.view)
        authorizationViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadData(_ isSuccess: Bool) {
        guard isSuccess else {
            HUD.show(with: "Error to load viewer info.")
            return
        }
        UIApplication.shared.keyWindow?.rootViewController = TabBarController()

        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await DeveloperGroupManager.shared.updateAll()
                }
                group.addTask {
                    await UserFollowingManager.shared.fetchUserFollowingStatus()
                }
            }
        }
    }

}
