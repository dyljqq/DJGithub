//
//  Consts.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

struct FrameGuide {
  static let screenWidth = UIScreen.main.bounds.size.width
  static let screenHeight = UIScreen.main.bounds.size.height

  static var currentKeyWindow: UIWindow? {
    var window: UIWindow?
    if #available(iOS 13.0, *) {
      for scene in UIApplication.shared.connectedScenes {
        if let scene = scene as? UIWindowScene, scene.activationState == .foregroundActive {
          window = scene.windows.first
          break
        }
      }
    } else {
      window = UIApplication.shared.keyWindow
    }
    return UIApplication.shared.keyWindow
  }

  static var statusBarHeight: CGFloat {
    var statusHeight: Double = 0

    if #available(iOS 13.0, *) {
      if let window = self.currentKeyWindow {
        statusHeight = CGFloat(window.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0)
      }
    } else {
      statusHeight = UIApplication.shared.statusBarFrame.size.height
    }

    return UIApplication.shared.statusBarFrame.size.height
  }

  static var isNotchScreen: Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return false
    }

    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width / size.height * 100)
    return 216 == notchValue || 46 == notchValue
  }

  static let navigationBarHeight: CGFloat = 44
  static var navigationBarAndStatusBarHeight: CGFloat {
    return self.navigationBarHeight + statusBarHeight
  }

  static var safeAreaInsets: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? UIEdgeInsets.zero
  }

  static var tabbarHeight: CGFloat {
    return isNotchScreen ? 83 : 49
  }
}
