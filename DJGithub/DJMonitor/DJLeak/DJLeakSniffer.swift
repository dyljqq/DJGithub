//
//  DJLeakSniffer.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import UIKit

class DJLeakSniffer {
  
  static let shared = DJLeakSniffer()
  
  private var timer: Timer?
  
  init() {
    NotificationCenter.default.addObserver(forName: .snifferPong, object: nil, queue: .main, using: { [weak self] noti in
      self?.detectPong(with: noti)
    })
  }
  
  func install() {
    NSObject.prepareForSniffer()
    self.startPing()
  }
  
  private func startPing() {
    if !Thread.isMainThread {
      DispatchQueue.main.async {
        self.startPing()
      }
      return
    }
    
    if timer != nil {
      return
    }
    
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: .snifferPing, object: nil)
      }
    })
  }
  
  private func detectPong(with noti: Notification) {
    print("-------------")
    let leakObject = noti.object
    if let vc = leakObject as? UIViewController {
      print("Detect controller leak: \(vc.classForCoder)")
    } else if let view = leakObject as? UIView {
      print("Detect view leak: \(view.classForCoder)")
      print("Responser VC: \(view.responseVC)")
      var v = view.superview
      while v != nil {
        print("super view: \(v)")
        v = v?.superview
      }
    } else {
      print("something may be leaked: \(leakObject)")
    }
    print("-------------")
  }
  
}
