//
//  UnChecked.swift
//  DJGithub
//
//  Created by polaris dev on 2025/4/18.
//

import Foundation

struct UnChecked<T>: @unchecked Sendable {
    var value: T
}
