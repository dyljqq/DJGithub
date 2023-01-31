//
//  URLRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

private let baseScheme = "djgithub"

enum URLJumpType {
    case `internal`, outside
}

struct URLRouter {
    static func open(with urlString: String?, jumpType: URLJumpType = .internal) {
        switch jumpType {
        case .outside:
            if let urlString, let url = URL(string: urlString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case .internal:
            guard let model = urlString?.urlRouterModel else { return }
            switch model.transition {
            case .push: pushVC(model.vc)
            case .present: break
            }
        }
    }

    static func pushVC(_ vc: UIViewController?) {
        guard let vc, let navi = getCurrentNavigation() else { return }
        navi.pushViewController(vc, animated: true)
    }

    static func getCurrentNavigation() -> UINavigationController? {
        guard let window = UIApplication.shared.keyWindow else { return nil }
        if let rootVC = window.rootViewController as? UITabBarController,
           let navi = rootVC.selectedViewController as? UINavigationController {
            return navi
        }
        return nil
    }
}

extension String {
    var urlRouterModel: URLRouterModel? {
        guard let urlString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString),
              let host = url.host else { return nil }
        guard let scheme = url.scheme else { return nil }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        var queryItems: [String: String] = [:]
        var type: HostVCType? = .unknown
        if host == "github.com" {
            type = .github
            let path = components.path
            let arr = path.components(separatedBy: "/").filter { !$0.isEmpty }
            if arr.count == 2 {
                queryItems = [
                    "userName": arr[0],
                    "repoName": arr[1]
                ]
            }
        } else if scheme.hasPrefix("http") {
            type = .web
            queryItems = ["url": urlString]
        } else {
            type = HostVCType(rawValue: host)
            for item in (components.queryItems ?? [] ) {
                queryItems[item.name] = item.value
            }
        }

        return URLRouterModel(scheme: scheme, host: host, path: url.path, type: type, queryItems: queryItems)
    }
}
