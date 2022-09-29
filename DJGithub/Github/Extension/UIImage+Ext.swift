//
//  UIImage+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

extension UIImageView {
  
  func setImage(with url: URL?) {
    self.kf.setImage(with: url)
  }
  
  func setImage(with urlString: String) {
    self.kf.setImage(with: URL(string: urlString))
  }
  
}
