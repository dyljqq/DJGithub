//
//  WebViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/26.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

  enum LoadType {
    case local, remote
  }

  var request: URLRequest? = nil
  let content: String
  var type: LoadType = .remote
  let urlString: String
  
  // token
  var titleToken: NSKeyValueObservation?
  var progressToken: NSKeyValueObservation?
  
  // nice job!!!!
  let photoJS = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}"
  
  lazy var userScript: WKUserScript = {
      let us = WKUserScript(source: photoJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
      return us
  }()
  
  lazy var userContentController: WKUserContentController = {
     let userContentController = WKUserContentController()
      userContentController.addUserScript(userScript)
      return userContentController
  }()
  
  lazy var webConfig: WKWebViewConfiguration = {
    let config = WKWebViewConfiguration()
      config.userContentController = userContentController
      return config
  }()
  
  lazy var webView: WKWebView = {
    let webView = WKWebView(frame: .zero, configuration: webConfig)
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
    self.content = urlString
    super.init(nibName: nil, bundle: nil)
    
    if let url = URL(string: urlString) {
      self.request = URLRequest(url: url)
    }
  }
  
  init(with content: String, type: LoadType = .remote) {
    self.content = content
    self.type = type
    if case LoadType.remote = type {
      urlString = content
    } else {
      urlString = ""
    }
    super.init(nibName: nil, bundle: nil)
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
      make.bottom.equalTo(footerView.snp.top)
      make.leading.trailing.equalTo(self.view)
    }
    footerView.snp.makeConstraints { make in
      make.height.equalTo(FrameGuide.tabbarHeight)
      make.leading.trailing.bottom.equalTo(self.view)
    }
    
    switch type {
    case .remote: loadFromRemote()
    case .local: loadFromLocal()
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
  
  private func loadFromRemote() {
    if let req = self.request {
      self.webView.load(req)
    }
  }
  
  private func loadFromLocal() {
    let html: String
    if let path = Bundle.main.path(forResource: "css", ofType: "html"),
       let style = try? String(contentsOfFile: path) {
      html = "\(style)\(content)"
    } else {
      html = content
    }
    webView.loadHTMLString(html, baseURL: nil)

  }
  
  private func addObserve() {
    titleToken = self.webView.observe(\.title) { [weak self] webView, _ in
      self?.navigationItem.title = webView.title
    }
    progressToken = self.webView.observe(\.estimatedProgress) { [weak self] webView, progress in
      if webView.estimatedProgress >= 1  {
        self?.view.stopLoading()
      }
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
    
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    
  }
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }
}
