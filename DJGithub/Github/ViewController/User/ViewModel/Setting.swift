//
//  Setting.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/31.
//

import Foundation

@Observable class Setting {

    let dataSource: [SettingSection] = [
        SettingSection(name: "Abillity", items: [.iCloud]),
        SettingSection(name: "Social", items: [.github, .email, .weibo]),
        SettingSection(name: "Other", items: [.version(Bundle.main.appVersion), .signUp])
    ]

}

extension Setting {
    struct SettingSection {
        let id = UUID()

        let name: String
        let items: [SettingType]
    }
}
