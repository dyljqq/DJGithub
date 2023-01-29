//
//  RssFeedItem.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/29.
//

import SwiftUI

struct RssFeedItem: View {

    let item: RssFeedLatestCellModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.textColor)
                    .lineLimit(2)
                HStack {
                    Text(item.from)
                        .font(.subheadline)
                        .foregroundColor(.textGrayColor)
                        .lineLimit(1)
                    Spacer()
                    Text(item.date)
                        .font(.subheadline)
                        .foregroundColor(.textGrayColor)
                }
            }
            Spacer()
        }
    }
}

struct RssFeedItem_Previews: PreviewProvider {
    static var previews: some View {
        RssFeedItem(item: RssFeedLatestCellModel.example)
    }
}
