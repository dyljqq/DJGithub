//
//  LoadingView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct LoaderView: View {

    var tintColor: Color = .blue
    var scaleSize: CGFloat = 1.0

    var body: some View {
        ProgressView()
            .scaleEffect(scaleSize, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
