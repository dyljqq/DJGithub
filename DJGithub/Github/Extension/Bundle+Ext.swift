//
//  Bundle+Ext.swift
//  DJGithub
//
//  Created by polaris dev on 2023/2/1.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
}
