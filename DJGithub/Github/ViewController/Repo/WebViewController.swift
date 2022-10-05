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
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.leading.bottom.trailing.equalTo(self.view)
    }
    
    if let req = self.request {
      webView.load(req)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    print("webView: \(webView.frame)")
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
