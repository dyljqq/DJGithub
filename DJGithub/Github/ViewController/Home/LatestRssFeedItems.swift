//
//  LatestRssFeedItems.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/29.
//

import SwiftUI

struct LatestRssFeedItems: View {

    let items: [RssFeedLatestCellModel]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Latest Feeds: ")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.leading, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<items.count, id: \.self) { index in
                        RssFeedItem(item: items[index])
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .frame(width: 300, height: 90)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                            }
                    }
                }
                .padding(.leading, 16)
            }
            .padding(.bottom, 10)
        }
        .background(Color.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 140)
    }
}

struct LatestRssFeedItems_Previews: PreviewProvider {
    static var previews: some View {
        LatestRssFeedItems(
            items: [
                RssFeedLatestCellModel.example,
                RssFeedLatestCellModel.example,
                RssFeedLatestCellModel.example,
                RssFeedLatestCellModel.example
            ]
        )
    }
}
