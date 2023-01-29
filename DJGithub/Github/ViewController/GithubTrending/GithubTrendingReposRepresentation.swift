//
//  GithubTrendingReposRepresentation.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation
import SwiftUI

struct GithubTrendingReposRepresentation: UIViewControllerRepresentable {

    let userName: String
    let repoName: String

    func makeUIViewController(context: Context) -> some UIViewController {
        return RepoViewController(with: userName, repoName: repoName)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
