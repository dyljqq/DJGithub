//
//  RepoContentFileViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit
import MarkdownView

class RepoContentFileViewController: UIViewController {
  let urlString: String
  var repoContent: RepoContent?
  
  lazy var fileView: MarkdownView = {
    let view = MarkdownView()
    return view
  }()
  
  lazy var fileImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .backgroundColor
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  init(with urlString: String) {
    self.urlString = urlString
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
    
    Task {
      self.repoContent = await RepoManager.getRepoContentFile(with: self.urlString)
      self.navigationItem.title = self.repoContent?.name
      
      if let urlString = self.repoContent?.downloadUrl,
         let fileSuffix = self.repoContent?.name.fileSuffix,
         ["bmp", "jpg", "jpeg", "png", "gif"].contains(fileSuffix) {
        view.addSubview(scrollView)
        scrollView.addSubview(self.fileImageView)
        scrollView.snp.makeConstraints { make in
          make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
          make.leading.trailing.bottom.equalToSuperview()
        }
        self.fileImageView.setImage(with: urlString) { [weak self] image in
          guard let strongSelf = self, let size = image?.size else { return }
          let minWidth = min(FrameGuide.screenWidth - 24, size.width)
          let height = size.height * minWidth / size.width
          if (FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight) < height {
            strongSelf.fileImageView.snp.makeConstraints { make in
              make.height.equalTo(height)
              make.leading.equalTo(12)
              make.top.equalToSuperview()
              make.width.equalTo(minWidth)
            }
          } else {
            strongSelf.fileImageView.snp.makeConstraints { make in
              make.center.equalToSuperview()
              make.width.equalTo(minWidth)
              make.height.equalTo(height)
            }
          }
          strongSelf.scrollView.contentSize = CGSize(width: FrameGuide.screenWidth, height: max(height, FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight))
        }
        return
      }
      
      view.addSubview(fileView)
      fileView.snp.makeConstraints { make in
        make.edges.equalTo(self.view)
      }
      if let content = self.repoContent?.content,
         let data = NSData(base64Encoded: content, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as? Data,
         let decodedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
        if let fileSuffix = self.repoContent?.name.fileSuffix,
           fileSuffix != "md" {
          self.fileView.load(markdown: "```\(decodedString)```", enableImage: true)
        } else {
          self.fileView.load(markdown: decodedString, enableImage: true)
        }
      }
    }
    
    fileView.onTouchLink = { [weak self] request in
      guard let strongSelf = self else { return false }
      strongSelf.navigationController?.pushToWebView(request: request)
      return false
    }
  }

}
