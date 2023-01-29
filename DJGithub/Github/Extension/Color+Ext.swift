//
//  Color+Ext.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

extension Color {
    init(with hex: String) {
        if let color = hex.toColor {
            self.init(uiColor: color)
        } else {
            self.init(white: 1)
        }
    }
    
    init(with red: CGFloat, green: CGFloat, blue: CGFloat) {
        let color = UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
        self.init(uiColor: color)
    }
}

extension Color {
    static let textColor = Color(uiColor: .textColor)
    static let textGrayColor = Color(uiColor: .textGrayColor)
    static let backgroundColor = Color(uiColor: .backgroundColor)
}
