//
//  Untitled.swift
//  DJGithub
//
//  Created by polaris dev on 2025/4/18.
//

import Foundation

@MainActor func executeOnMainThread(_ block: @escaping () -> Void) {
    Task {
        await MainActor.run {
            block()
        }
    }
}
