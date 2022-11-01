//
//  DJCrashManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/1.
//

import UIKit

typealias SigactionHandler = @convention(c)(Int32) -> Void

enum DJCrashExceptionKey {
  case address
  case signal
  case signalException
  
  var key: String {
    switch self {
    case .address: return "UncaughtExceptionHandlerAddressesKey"
    case .signal: return "UncaughtExceptionHandlerSignalKey"
    case .signalException: return "UncaughtExceptionHandlerSignalExceptionName"
    }
  }
}

class DJCrashManager: NSObject {
  
  static let shared = DJCrashManager()
  
  var dismissed: Bool = false
  var lastExceptionHandler: (@convention(c) (NSException) -> Void)?
  
  let SignalHandler: @convention(c) (Int32) -> Void = { sig in
    var userInfo: [String: Any] = [:]
    userInfo[DJCrashExceptionKey.signal.key] = "\(sig)"
    userInfo[DJCrashExceptionKey.address.key] = DJCrashManager.shared.stackSymbolsStr()
    
    let signalException = NSException(name: NSExceptionName(DJCrashExceptionKey.signalException.key), reason: "Signal \(sig) was raised.", userInfo: userInfo)
    DJCrashManager.shared.perform(#selector(handle(with:)), on: .main, with: signalException, waitUntilDone: true)
  }
  
  let myExceptionHandler: (@convention(c) (NSException) -> Void)? = { exception in
    guard var info = exception.userInfo else { return }
    info[DJCrashExceptionKey.address.key] = DJCrashManager.shared.stackSymbolsStr()
    let exception = NSException(name: exception.name, reason: exception.reason, userInfo: info)
    DJCrashManager.shared.perform(#selector(handle(with:)), on: .main, with: exception, waitUntilDone: true)
    DJCrashManager.shared.lastExceptionHandler?(exception)
  }
  
  func registerHandler() {
    registerSignalHandler()
    registerExceptionHandler()
  }
  
  func registerSignalHandler() {
    signal(SIGHUP, SignalHandler)
    signal(SIGINT, SignalHandler)
    signal(SIGQUIT, SignalHandler)
    signal(SIGABRT, SignalHandler)
    signal(SIGILL, SignalHandler)
    signal(SIGSEGV, SignalHandler)
    signal(SIGFPE, SignalHandler)
    signal(SIGBUS, SignalHandler)
    signal(SIGPIPE, SignalHandler)
  }
  
  func registerExceptionHandler() {
    self.lastExceptionHandler = NSGetUncaughtExceptionHandler()
    NSSetUncaughtExceptionHandler(myExceptionHandler)
  }
  
  @objc func handle(with exception: NSException) {
    guard let stack = exception.userInfo?[DJCrashExceptionKey.address.key] as? String else { return }

    DJCrashLogManager.collect(with: exception, stackInfo: stack, viewControllerInfo: getCurrentVCStackInfo())
    NSSetUncaughtExceptionHandler(nil)

    signal(SIGHUP, SIG_DFL)
    signal(SIGINT, SIG_DFL)
    signal(SIGQUIT, SIG_DFL)
    signal(SIGABRT, SIG_DFL)
    signal(SIGILL, SIG_DFL)
    signal(SIGSEGV, SIG_DFL)
    signal(SIGFPE, SIG_DFL)
    signal(SIGBUS, SIG_DFL)
    signal(SIGPIPE, SIG_DFL)

    if exception.name.rawValue == DJCrashExceptionKey.signalException.key,
       let value = exception.userInfo?[DJCrashExceptionKey.signal] as? String,
       let intValue = Int32(value) {
      kill(getpid(), intValue)
    } else {
      exception.raise()
    }
  }
  
  func showCrashToast(with message: String) {
    let vc = UIAlertController(title: "Crash", message: message, preferredStyle: .alert)
    vc.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
      
    }))
    vc.addAction(UIAlertAction(title: "Exit", style: .cancel, handler: { action in
      self.dismissed = true
    }))
    let rootVC = UIApplication.shared.keyWindow?.rootViewController
    if let rootVC = rootVC as? UITabBarController,
       let selectedVC = rootVC.viewControllers?[rootVC.selectedIndex] as? UINavigationController {
      selectedVC.topViewController?.present(vc, animated: true)
    }
  }
  
  private func getCurrentVCStackInfo() -> String {
    guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return "" }
    var stackInfo: [String] = [NSStringFromClass(vc.classForCoder)]
    if let rootVc = vc as? UINavigationController {
      stackInfo = rootVc.viewControllers.reduce(stackInfo) { $0 + [NSStringFromClass($1.classForCoder)] }
    } else if let rootVC = vc as? UITabBarController, let navi = rootVC.selectedViewController as? UINavigationController {
      stackInfo = navi.viewControllers.reduce(stackInfo) { $0 + [NSStringFromClass($1.classForCoder)] }
    }
    return stackInfo.joined(separator: "-")
  }
  
  func stackSymbolsStr() -> String? {
    let symbols = Thread.callStackSymbols
    if let data = try? JSONSerialization.data(withJSONObject: symbols) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
  
}

private var tapClosureKey: UInt8 = 0

fileprivate extension UIView {
  
  var tapClosure: ((Bool) -> ())? {
    get {
      return objc_getAssociatedObject(self, &tapClosureKey) as? ((Bool) -> ())
    }
    set {
      objc_setAssociatedObject(self, &tapClosureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  func addTapGesture(_ tapClosure: @escaping (Bool) -> ()) {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(tap)
    self.tapClosure = tapClosure
  }
  
  @objc func tapAction(tap: UITapGestureRecognizer) {
    guard let label = tap.view as? UILabel else { return }
    UIPasteboard.general.string = label.text
    tapClosure?(true)
  }
}
