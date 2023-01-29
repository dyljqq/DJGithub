//
//  RssFeedsItemView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/29.
//

import SwiftUI

struct RssFeedsItemView: View {
    
    let title: String
    let desc: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.textColor)
            Text(desc)
                .font(.system(size: 12))
                .foregroundColor(.textGrayColor)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

struct RssFeedsItemView_Previews: PreviewProvider {
    static var previews: some View {
        RssFeedsItemView(
            title: "rss feed title", desc: "rss feed content"
        )
    }
}
