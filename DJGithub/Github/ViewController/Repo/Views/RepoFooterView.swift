//
//  RepoFooterView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit
import WebKit
import MarkdownView

class RepoFooterView: UIView {
  
  var fetchHeightClosure: ((CGFloat) -> Void)?
  var touchLink: ((URLRequest?) -> Void)?

  lazy var mdView: MarkdownView = {
    let mdView = MarkdownView()
    return mdView
  }()
  
  init() {
    super.init(frame: .zero)
    
    addSubview(self.mdView)
    mdView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    
    self.mdView.onRendered = { [weak self] height in
      self?.fetchHeightClosure?(height)
    }
    
    self.mdView.onTouchLink = { [weak self] req in
      self?.touchLink?(req)
      return false
    }
  }
  
  func render(with content: String?) {
    guard let content = content else { return }
    DispatchQueue.global().async {
      if let data = NSData(base64Encoded: content, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as? Data,
         let decodedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
        DispatchQueue.main.async {
          self.mdView.load(markdown: decodedString, enableImage: true)
        }
      }
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
}
