//
//  RefreshView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import UIKit

enum RefreshPosition {
  case header, footer
}

enum RefreshState {
  case begin
  case end
  case unknown
}

protocol RefreshStatus {
  func didUpdateState(_ isRefreshing: Bool)
  func didUpdateProgress(_ progress: CGFloat)
}

class RefreshView: UIView, RefreshStatus {
  
  let refreshPosition: RefreshPosition
  let height: CGFloat
  let action: () -> Void
  
  var offsetToken: NSKeyValueObservation?
  var stateToken: NSKeyValueObservation?
  var sizeToken: NSKeyValueObservation?
  
  var isRefreshing = false {
    didSet {
      didUpdateState(isRefreshing)
    }
  }
  
  var progress: CGFloat = 0 {
    didSet {
      didUpdateProgress(progress)
    }
  }
  
  var scrollView: UIScrollView? {
    return superview as? UIScrollView
  }
  
  var refreshState: RefreshState = .unknown
  
  init(refreshPosition: RefreshPosition, height: CGFloat, action: @escaping () -> Void) {
    self.refreshPosition = refreshPosition
    self.height = height
    self.action = action
    super.init(frame: .zero)    
    self.autoresizingMask = [.flexibleWidth]
  }
  
  func didUpdateState(_ isRefreshing: Bool) {
    fatalError("didUpdateState has not been implemented")
  }
  
  func didUpdateProgress(_ progress: CGFloat) {
    fatalError("didUpdateProgress has not been implemented")
  }
  
  override func willMove(toWindow newWindow: UIWindow?) {
    guard let _ = newWindow else {
      clearObserver()
      return
    }
    
    guard let scrollView = scrollView else {
      return
    }
    setUpObserver(scrollView)
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    guard let scrollView = newSuperview as? UIScrollView else {
      clearObserver()
      return
    }
    setUpObserver(scrollView)
  }
  
  func setUpObserver(_ scrollView: UIScrollView) {
    offsetToken = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
      guard let strongSelf = self else { return }
      
      if case .footer = strongSelf.refreshPosition {
        let offsetY = scrollView.contentSize.height - scrollView.bounds.height - 10
        if offsetY < 0 {
          strongSelf.isHidden = true
        } else {
          strongSelf.isHidden = scrollView.contentOffset.y <= offsetY
        }
      }
      strongSelf.scrollViewDidScroll(scrollView)
    }
    
    stateToken = scrollView.observe(\.panGestureRecognizer.state) { [weak self] scrollView, _ in
      guard scrollView.panGestureRecognizer.state == .ended else {
        return
      }
      self?.scrollViewDidEndDragging(scrollView)
    }
    
    switch refreshPosition {
    case .header:
      frame = CGRect(x: 0, y: -height, width: scrollView.bounds.width, height: height)
    case .footer:
      sizeToken = scrollView.observe(\.contentSize) { [weak self] scrollView, _ in
        guard let strongSelf = self else {
          return
        }
        strongSelf.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: strongSelf.height)
      }
    }
  }
  
  func clearObserver() {
    offsetToken?.invalidate()
    stateToken?.invalidate()
    sizeToken?.invalidate()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard !isRefreshing && height > 0 else {
      return
    }
    
    switch refreshPosition {
    case .header:
      progress = min(1, max(0, -(scrollView.contentOffset.y + scrollView.contentInsetTop) / height))
    case .footer:
      progress = min(1, max(0, (scrollView.contentOffset.y + scrollView.bounds.height - scrollView.contentSize.height - scrollView.contentInsetBottom) / height))
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
    if isRefreshing || progress < 1 {
      return
    }
    beginRefreshing()
  }
  
  func beginRefreshing() {
    refreshState = .begin
    guard let scrollView = scrollView else {
      return
    }
    
    progress = 1
    isRefreshing = true

    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.3, animations: {
        switch self.refreshPosition {
        case .header:
          scrollView.contentOffset.y = -self.height - scrollView.contentInsetTop
          scrollView.contentInset.top = self.height
        case .footer:
          scrollView.contentInset.bottom = self.height
        }
      }, completion: { _ in
        self.action()
      })
    }
  }
  
  func endRefreshing(with completionHandler: (() -> Void)? = nil) {
    refreshState = .end
    guard let scrollView = scrollView else {
      completionHandler?()
      return
    }

    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.3, animations: {
        switch self.refreshPosition {
        case .header:
          scrollView.contentInset.top = 0
        case .footer:
          scrollView.contentInset.bottom = 0
        }
      }, completion: { _ in
        self.isRefreshing = false
        self.progress = 0
        self.refreshState = .unknown
        completionHandler?()
      })
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    self.clearObserver()
  }
  
}
