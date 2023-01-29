//
//  AuthorizationViewManager.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/28.
//

import Foundation
import SwiftUI

class AuthorizationViewManager: NSObject {

    func addAuthorizationView(_ completionHandler: ((Bool) -> Void)? = nil) -> UIViewController {
        let authorizationView = AuthorizationView(completionHandler: completionHandler)
        return UIHostingController(rootView: authorizationView)
    }

}
