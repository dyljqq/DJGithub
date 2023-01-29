//
//  GithubTrendingManager.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation
import SwiftUI

class GithubTrendingManager: NSObject {

    func addTrendingView(with types: [GithubTrendingType],
                         selectedIndex: Int = 0,
                         repoSelectedClosure: @escaping (GithubTrendingRepo) -> Void,
                         developerSelectedClosure: @escaping (GithubTrendingDeveloper) -> Void) -> UIViewController {
        return UIHostingController(
            rootView: GithubTrendingView(
                types: types,
                selectedIndex: selectedIndex,
                repoSelectedClosure: repoSelectedClosure,
                developerSelectedClosure: developerSelectedClosure
            )
        )
    }

}
