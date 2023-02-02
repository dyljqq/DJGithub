//
//  RssFeedsView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/29.
//

import SwiftUI

struct RssFeedsView: View {

    let atom: RssFeedAtom
    var itemDidSelectClosure: ((RssFeed) -> Void)?

    @State var feeds: [RssFeed] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(feeds, id: \.id) { feed in
                    VStack(spacing: 0) {
                        RssFeedsItemView(
                            title: feed.title,
                            desc: feed.displayDateString
                        )
                        Divider()
                            .padding(.top, 10)
                    }
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
                    .onTapGesture {
                        itemDidSelectClosure?(feed)
                    }
                }
            }
        }
        .onViewDidLoad {
            self.loadData()
        }
    }

    private func loadData() {
        Task {
            self.feeds = await RssFeedManager.getFeeds(by: atom.id)
            let isUpdated = await RssFeedManager.shared.loadFeeds(by: atom)
            if isUpdated {
                self.feeds = await RssFeedManager.getFeeds(by: atom.id)
            }
        }
    }
}

fileprivate extension RssFeed {
  var displayDateString: String {
    return "updated on \(self.updated.components(separatedBy: " ").first ?? self.updated)"
  }
}
