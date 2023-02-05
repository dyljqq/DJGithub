//
//  SettingViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/2/1.
//

import UIKit
import SwiftUI

class SettingViewController: UIViewController {

    lazy var vc: UIViewController = {
        let settingView = SettingView { [weak self] type in
            self?.itemDidSelected(with: type)
        }
        let vc = UIHostingController(rootView: settingView)
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor
        navigationItem.title = "Setting"

        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    func itemDidSelected(with type: SettingType) {
        switch type {
        case .email: URLRouter.open(with: "mailto: \(type.title)", jumpType: .outside)
        case .weibo: URLRouter.open(with: "sinaweibo://userinfo?uid=2579435503", jumpType: .outside)
        case .github: URLRouter.open(with: "djgithub://user?name=dyljqq")
        case .signUp:
            DJUserDefaults.clearViewerInfo()
            UIApplication.shared.keyWindow?.rootViewController = LoadingViewerViewController()
        default: break
        }
    }

}
