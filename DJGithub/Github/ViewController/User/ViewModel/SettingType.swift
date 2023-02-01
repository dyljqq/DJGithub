//
//  SettingType.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/31.
//

import Foundation

enum SettingType {
    case iCloud
    case email, weibo, github
    case version(String)
}

extension SettingType {
    var title: String {
        switch self {
        case .email: return "355086587@qq.com"
        case .weibo: return "@JJJJJJJiqqqq"
        case .github: return "东方宜玲"
        case .iCloud: return "iCloud"
        case .version(let version): return "App Version: \(version)"
        }
    }

    var iconName: String {
        switch self {
        case .email: return "email"
        case .weibo: return "weibo"
        case .github: return "github"
        default: return ""
        }
    }
}
