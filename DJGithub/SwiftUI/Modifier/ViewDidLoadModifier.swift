//
//  ViewDidLoadModifier.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/2/2.
//

import SwiftUI

struct ViewDidLoadModifer: ViewModifier {
    @State private var viewDidLoad = false

    var action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !viewDidLoad {
                    viewDidLoad = true
                    action?()
                }
            }
    }

}

extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifer(action: action))
    }
}
