//
//  GithubTrendingManager.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation
import SwiftUI

class GithubTrendingManager: NSObject {
    
    @objc func addTrendingRepoView(with path: String, pushClosure: ((String, String) -> Void)? = nil) -> UIViewController {
        return UIHostingController(
            rootView: GithubTrendingReposView(
                path: path,
                pushClosure: pushClosure
            )
        )
    }
    
}
