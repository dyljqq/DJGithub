//
//  GithubTrendingRepoHostingController.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation
import SwiftUI

class GithubTrendingRepoHostingController: NSObject {
    
    func addTrendingRepoView(with path: String) -> UIViewController {
        return UIHostingController(rootView: GithubTrendingReposView(path: path))
    }
    
}
