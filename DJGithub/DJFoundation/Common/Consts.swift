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
  static let shared = FrameGuide()
  
  let screenWidth = UIScreen.main.bounds.size.width
  let screenHeight = UIScreen.main.bounds.size.height
  
  lazy var currentKeyWindow: UIWindow? = {
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
    return window
  }()
  
  lazy var statusBarHeight: CGFloat = {
    var statusHeight: Double = 0
    
    if #available(iOS 13.0, *) {
      if let window = self.currentKeyWindow {
        statusHeight = CGFloat(window.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0)
      }
    } else {
      statusHeight = UIApplication.shared.statusBarFrame.size.height
    }
    
    return statusHeight
  }()
  
  var isNotchScreen: Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return false
    }
    
    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width / size.height * 100)
    return 216 == notchValue || 46 == notchValue
  }
  
  let navigationBarHeight: CGFloat = 44
  lazy var navigationBarAndStatusBarHeight: CGFloat = {
    return navigationBarHeight + statusBarHeight
  }()
}
