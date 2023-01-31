//
//  GithubTrendingItemView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import SwiftUI

struct GithubTrendingItemView<ChildView: View>: View {

    let views: [ChildView]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(0..<views.count, id: \.self) { index in
                    views[index]
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white)
                        }
                        .frame(maxWidth: 300)
                }
            }
            .padding(.leading, 16)
        }
        .background(Color.backgroundColor)
    }
}
