//
//  AvatarImageView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/10.
//

import UIKit

class AvatarImageView: UIImageView {
  
  struct AvatarModel {
    let imageUrl: String
    let placeholder: UIImage?
    let userName: String?
    
    init(imageUrl: String, placeholder: UIImage? = nil, userName: String?) {
      self.imageUrl = imageUrl
      self.placeholder = placeholder
      self.userName = userName
    }
  }
  
  private var model: AvatarModel?
  
  init() {
    super.init(frame: .zero)
    setUp()
  }
  
  func render(with model: AvatarModel) {
    self.model = model
    self.setImage(with: model.imageUrl, placeHolder: model.placeholder)
  }
  
  @objc func jumpAction() {
    jumpToUserViewController(with: model?.userName)
  }
  
  private func setUp() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(jumpAction))
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(tap)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension AvatarImageView {
  fileprivate func jumpToUserViewController(with userName: String?) {
    guard let userName = userName, !userName.isEmpty else { return }
    var next = self.next
    while next != nil {
      if let vc = next as? UIViewController {
        if let navi = vc.navigationController {
          navi.pushToUser(with: userName)
        }
        return
      }
      next = next?.next
    }
    return
  }
}
