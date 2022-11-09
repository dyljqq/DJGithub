//
//  RssFeedDetailViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit
import WebKit
import SafariServices

class RssFeedDetailViewController: UIViewController {

  let rssFeed: RssFeed
  
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
  
  init(rssFeed: RssFeed) {
    self.rssFeed = rssFeed
    super.init(nibName: nil, bundle: nil)
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
    navigationItem.title = rssFeed.title
    
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    let content: String
    if let path = Bundle.main.path(forResource: "css", ofType: "html"),
       let style = try? String(contentsOfFile: path) {
      content = "\(style)\(rssFeed.content) <br /> <a href=\"\(rssFeed.link)\">阅读全文</a>"
    } else {
      content = rssFeed.content
    }
    webView.loadHTMLString(content, baseURL: nil)
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .action, target: self, action: #selector(shareTo))
  }
  
  @objc func shareTo() {
    share(with: rssFeed.link)
  }

}

extension RssFeedDetailViewController: WKNavigationDelegate, WKUIDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if case WKNavigationType.other = navigationAction.navigationType {
      decisionHandler(.allow)
    } else {
      if let url = navigationAction.request.url {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
      }
      decisionHandler(.cancel)
    }
  }
}
