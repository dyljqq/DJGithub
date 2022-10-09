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
    
    view.addSubview(fileView)
    view.addSubview(fileImageView)
    fileView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    fileImageView.snp.makeConstraints { make in
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight)
      make.centerX.equalTo(self.view)
      make.width.height.equalTo(50)
    }
    
    Task {
      self.repoContent = await RepoManager.getRepoContentFile(with: self.urlString)
      self.navigationItem.title = self.repoContent?.name
      
      if let urlString = self.repoContent?.downloadUrl,
         let fileSuffix = self.repoContent?.name.fileSuffix,
         ["bmp", "jpg", "jpeg", "png", "gif"].contains(fileSuffix) {
        self.fileImageView.setImage(with: urlString) { [weak self] image in
          guard let strongSelf = self, let size = image?.size else { return }
          let minWidth = min(FrameGuide.screenWidth - 24, size.width)
          strongSelf.fileImageView.snp.updateConstraints { make in
            make.width.equalTo(minWidth)
            make.height.equalTo(size.height * minWidth / size.width)
          }
        }
        return
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
  }

}
