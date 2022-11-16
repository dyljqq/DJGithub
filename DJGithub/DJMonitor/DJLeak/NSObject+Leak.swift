//
//  NSObject+Leak.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import UIKit

private var proxyKey: UInt8 = 0

extension NSObject {

  var proxy: DJObjectProxy? {
    get {
      return objc_getAssociatedObject(self, &proxyKey) as? DJObjectProxy
    }
    set {
      objc_setAssociatedObject(self, &proxyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  static func prepareForSniffer() {
    DispatchQueue.once {
      UIViewController.swizzleInstanceMethod(
        origSelector: #selector(UIViewController.viewDidAppear(_:)),
        toAlterSelector: #selector(UIViewController.swizzled_viewDidAppear(_:))
      )
      UIViewController.swizzleInstanceMethod(
        origSelector: #selector(UIViewController.present(_:animated:completion:)),
        toAlterSelector: #selector(UIViewController.swizzled_present(_:animated:completion:))
      )
      UINavigationController.swizzleInstanceMethod(
        origSelector: #selector(UINavigationController.pushViewController(_:animated:)),
        toAlterSelector: #selector(UINavigationController.swizzled_pushViewController(_:animated:))
      )
      UIView.swizzleInstanceMethod(origSelector: #selector(UIView.didMoveToSuperview), toAlterSelector: #selector(UIView.swizzled_didMoveToSuperview))
    }
  }

  func markAlive() -> Bool {
    guard self.proxy == nil else { return false }
    let className = NSStringFromClass(self.classForCoder)
    guard !isSystemClass(className) else { return false }

    // 如果view没有父视图，则认为已经被释放了
    if let view = self as? UIView {
      if view.superview == nil {
        return false
      }
    }

    // 如果vc没有父控制器，则认为已经被释放
    if let vc = self as? UIViewController {
      if vc.navigationController == nil && vc.presentingViewController == nil {
        return false
      }
    }

    let pxy = DJObjectProxy()
    self.proxy = pxy
    pxy.prepareProxy(with: self)

    return true
  }

  func isSystemClass(_ className: String) -> Bool {
    return className.hasPrefix("_") || className.hasPrefix("UI") || className.hasPrefix("NS")
  }

  func isAlive() -> Bool {
    if let vc = self as? UIViewController {
      return judgeAlive(for: vc)
    } else if let v = self as? UIView {
      return judgeAlive(for: v)
    }
    return true
  }

  func watchAllProperties(with level: Int) {
    guard level <= 5 else { return }

    var properties: [DJProperty] = []
    let className = NSStringFromClass(self.classForCoder)
    guard !isSystemClass(className) else { return }

    properties.append(contentsOf: getAllProperties(by: self.classForCoder))
    properties.append(contentsOf: getAllProperties(by: self.superclass))
    properties.append(contentsOf: getAllProperties(by: self.superclass?.superclass()))

    for p in properties {
      guard let cur = self.value(forKey: p.name) as? NSObject else { continue }
      let ret = cur.markAlive()
      if ret {
        cur.proxy?.weakHost = self
        cur .watchAllProperties(with: level + 1)
      }
    }
  }

  // swift4.0之后无效
  func getAllProperties(by cls: AnyClass?) -> [DJProperty] {
    guard let cls = cls else { return [] }
    let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    let className = NSStringFromClass(cls)
    guard !isSystemClass(className) else { return [] }
    let ps = class_copyPropertyList(cls, count)
    defer { free(ps) }
    guard let ps = ps else { return [] }

    var properties: [DJProperty] = []
    for i in 0..<Int(count[0]) {
      let p = DJProperty(with: ps[i])
      if p.name == "DJObjectProxy" ||
          p.name.hasPrefix("UI") ||
          p.name.hasPrefix("NS") ||
          p.name.contains("KVO") ||
          !p.isStrong {
        continue
      }
      properties.append(p)
    }
    return properties
  }

}

extension NSObject {

  // 判断vc是否存活
  func judgeAlive(for vc: UIViewController) -> Bool {
    var alive = true
    var visibleOnScreen = false

    var v = vc.view
    while v?.superview != nil {
      v = v?.superview
    }
    if let v = v?.isKind(of: UIWindow.classForCoder()), v {
      visibleOnScreen = true
    }

    let beingHeld = vc.navigationController != nil || vc.presentingViewController != nil
    if !beingHeld && !visibleOnScreen {
      alive = false
    }
    return alive
  }

  // 判断UIView是否存活
  func judgeAlive(for view: UIView) -> Bool {
    var alive = true
    var onUIStack = false

    var v: UIView? = view
    while v?.superview != nil {
      v = v?.superview
    }

    if let v = v, v.isKind(of: UIWindow.classForCoder()) {
      onUIStack = true
    }

    if view.proxy?.responder == nil,
       let vc = view.responseVC {
      view.proxy?.responder = vc
    }

    if !onUIStack {
      alive = false

      if let v = view.proxy?.responder?.isKind(of: UIViewController.classForCoder()), v {
        alive = true
      }
    }

    return alive
  }
}

extension NSObject {
  static func swizzleInstanceMethod(origSelector: Selector, toAlterSelector alterSelector: Selector) {
    self.swizzleMethod(with: self.classForCoder(), originSel: origSelector, swizzledSel: alterSelector)
  }

  static func swizzleMethod(with cls: AnyClass, originSel: Selector, swizzledSel: Selector) {
    return self.swizzleMethod(with: self.classForCoder(), swizzledCls: cls, originSel: originSel, swizzledSel: swizzledSel)
  }

  static func swizzleMethod(with cls: AnyClass, swizzledCls: AnyClass?, originSel: Selector, swizzledSel: Selector) {
    guard let originMethod = class_getInstanceMethod(cls, originSel),
          let swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSel) else { return }

    let didAddMethod = class_addMethod(
      cls, swizzledSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
    if didAddMethod {
      class_replaceMethod(
        cls, swizzledSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
    } else {
      method_exchangeImplementations(originMethod, swizzledMethod)
    }
  }
}
