//
//  URLRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

private let baseScheme = "djgithub"

struct URLRouter {
  static func open(with urlString: String?) {
    guard let model = urlString?.urlRouterModel else { return }
    switch model.transition {
    case .push: pushVC(model.vc)
    case .present: break
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
    guard let url = URL(string: self) else { return nil }
    guard let scheme = url.scheme, scheme == baseScheme else { return nil }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    return URLRouterModel(scheme: scheme, host: url.host ?? "", path: url.path, queryItems: components.queryItems)
  }
}
