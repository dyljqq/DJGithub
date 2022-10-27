//
//  DJMaskView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import UIKit

struct DJMaskContentConfig {
  enum Position {
    case origin(CGPoint)
    case center
  }
  
  let view: UIView
  let size: CGSize
  let postion: Position
  
  init(view: UIView, size: CGSize, postion: Position = .center) {
    self.view = view
    self.size = size
    self.postion = postion
  }
}

class DJMaskView: UIView {
  
  let contentModel: DJMaskContentConfig
  
  class func show(with contentModel: DJMaskContentConfig) {
    guard let window = UIApplication.shared.keyWindow else { return }
    let maskView = DJMaskView(with: contentModel)
    window.addSubview(maskView)
    
    maskView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    let tap = UITapGestureRecognizer(target: maskView, action: #selector(DJMaskView.touchAction))
    maskView.addGestureRecognizer(tap)
    maskView.isUserInteractionEnabled = true
  }
  
  init(with contentModel: DJMaskContentConfig) {
    self.contentModel = contentModel
    super.init(frame: .zero)
    
    setUp()
  }
  
  private func setUp() {
    backgroundColor = UIColor.black.withAlphaComponent(0.3)
    addSubview(contentModel.view)
    contentModel.view.layer.cornerRadius = 10
    contentModel.view.layer.masksToBounds = true
    contentModel.view.snp.makeConstraints { make in
      make.size.equalTo(contentModel.size)
      switch contentModel.postion {
      case .origin(let origin):
        make.leading.equalTo(origin.x)
        make.top.equalTo(origin.y)
      case .center:
        make.center.equalToSuperview()
      }
    }
  }
  
  @objc func touchAction() {
    self.hide()
  }
  
  private func hide() {
    UIView.animate(withDuration: 0.3, animations: {
      self.alpha = 0
    }, completion: { stop in
      self.removeFromSuperview()
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
