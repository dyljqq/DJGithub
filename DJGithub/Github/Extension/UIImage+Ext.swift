//
//  UIImage+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

extension UIImage {
  static var defaultPersonImage: UIImage? {
    return UIImage(named: "person")
  }
}

extension UIImageView {
  
  func setImage(with url: URL?, placeHolder: UIImage? = nil) {
    self.kf.setImage(with: url, placeholder: placeHolder)
  }
  
  func setImage(with urlString: String, placeHolder: UIImage? = nil) {
    self.kf.setImage(with: URL(string: urlString), placeholder: placeHolder)
  }
  
  func setImage(with urlString: String?, placeHolder: UIImage? = nil) {
    self.kf.setImage(with: URL(string: urlString ?? ""), placeholder: placeHolder)
  }
  
  func setImage(with urlString: String?, placeHolder: UIImage? = nil, completionHandler: @escaping ((UIImage?) -> ())) {
    self.kf.setImage(with: URL(string: urlString ?? ""), placeholder: placeHolder, completionHandler: { result in
      switch result {
      case .success(let r):
        completionHandler(r.image)
      case .failure(let error):
        print("fetch image error: \(error)")
      }
    })
  }
  
}
