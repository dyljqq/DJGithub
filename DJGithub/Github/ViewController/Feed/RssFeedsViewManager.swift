//
//  RssFeedsViewManager.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/29.
//

import Foundation
import SwiftUI

class RssFeedsViewManager: NSObject {
    func addRssFeedsView(with atom: RssFeedAtom, itemDidSelectClosure: @escaping (RssFeed) -> Void) -> UIViewController {
        UIHostingController(rootView: RssFeedsView(atom: atom, itemDidSelectClosure: itemDidSelectClosure))
    }
}
