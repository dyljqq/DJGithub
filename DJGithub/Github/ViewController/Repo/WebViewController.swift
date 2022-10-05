//
//  WebViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/26.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

  let urlString: String
  var request: URLRequest? = nil
  
  // token
  var titleToken: NSKeyValueObservation?
  var progressToken: NSKeyValueObservation?
  
  lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = self
    webView.uiDelegate = self
    webView.isOpaque = false
    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.isDirectionalLockEnabled = true
    return webView
  }()
  
  lazy var footerView: WebViewFooterView = {
    let footView = WebViewFooterView()
    return footView
  }()
  
  init(with urlString: String) {
    self.urlString = urlString
    super.init(nibName: nil, bundle: nil)
    
    if let url = URL(string: urlString) {
      self.request = URLRequest(url: url)
    }
  }
  
  convenience init(with request: URLRequest?) {
    self.init(with: request?.url?.absoluteString ?? "")
    self.request = request
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
    addObserve()
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
    view.addSubview(webView)
    view.addSubview(footerView)
    webView.snp.makeConstraints { make in
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.leading.bottom.trailing.equalTo(self.view)
    }
    footerView.snp.makeConstraints { make in
      make.height.equalTo(FrameGuide.tabbarHeight)
      make.leading.trailing.bottom.equalTo(self.view)
    }
    
    if let req = self.request {
      webView.load(req)
    }
    
    view.startLoading()
    
    footerView.oprationClosure = { [weak self] operation in
      guard let strongSelf = self else { return }
      switch operation {
      case .reload:
        strongSelf.webView.reload()
      case .forward:
        strongSelf.webView.goForward()
      case .back:
        strongSelf.webView.goBack()
      }
    }
  }
  
  private func addObserve() {
    titleToken = self.webView.observe(\.title) { [weak self] webView, _ in
      self?.navigationItem.title = webView.title
    }
    progressToken = self.webView.observe(\.estimatedProgress) { [weak self] webView, progress in
      self?.view.stopLoading()
    }
  }
  
  private func clearObserve() {
    titleToken?.invalidate()
    progressToken?.invalidate()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }

  deinit {
    clearObserve()
  }
  
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("todo...")
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("failed...")
  }
}
