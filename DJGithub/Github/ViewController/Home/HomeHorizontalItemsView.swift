//
//  HomeHorizontalItemsView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import SwiftUI

struct HomeHorizontalItemsView<ChildView: View>: View {

    let title: String
    let horizontalView: ChildView

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.leading, 16)
            horizontalView
        }
        .background(Color.backgroundColor)
    }
}
