//
//  SettingView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/31.
//

import SwiftUI

struct SettingRow: View {
    let type: SettingType

    @State var isSync: Bool = false

    var body: some View {
        HStack {
            Text(type.title)
            Spacer()
            if case SettingType.iCloud = type {
                Toggle("sync to iCloud", isOn: $isSync)
            } else if let image = UIImage(named: type.iconName) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }

}

struct SettingView: View {

    @ObservedObject var setting = Setting()

    var itemDidSelectedClosure: (SettingType) -> Void

    var body: some View {
        List {
            ForEach(setting.dataSource, id: \.id) { section in
                Section(section.name) {
                    ForEach(0..<section.items.count, id: \.self) { index in
                        SettingRow(type: section.items[index])
                            .onTapGesture {
                                itemDidSelectedClosure(section.items[index])
                            }
                    }
                }
            }
        }
    }
}
