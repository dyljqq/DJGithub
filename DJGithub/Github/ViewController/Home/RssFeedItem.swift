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
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.textColor)
                    .lineLimit(2)
                    .padding(.top, 10)
                Spacer()
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
                .padding(5)
            }
        }
    }
}

struct RssFeedItem_Previews: PreviewProvider {
    static var previews: some View {
        RssFeedItem(item: RssFeedLatestCellModel.example)
    }
}
