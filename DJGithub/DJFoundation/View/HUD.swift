//
//  HUD.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/6.
//

import UIKit

private class HUDMessageView: UIView {
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .white
    return label
  }()
  
  lazy var effectView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: effect)
    return blurView
  }()
  
  init() {
    super.init(frame: .zero)
    
    setUp()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render(with content: String) {
    self.contentLabel.text = content
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    effectView.frame = bounds
  }
  
  private func setUp() {
    backgroundColor = UIColor.black.withAlphaComponent(0.8)
    
    layer.cornerRadius = 5
    layer.masksToBounds = true
    addSubview(effectView)
    
    addSubview(contentLabel)
    contentLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
  
}

class HUD {
  
  class func show(with content: String) {
    guard let window = UIApplication.shared.keyWindow else {
      return
    }
    let view = HUDMessageView()
    window.addSubview(view)
    
    view.frame = CGRect(x: 40, y: -44, width: FrameGuide.screenWidth - 80, height: 44)
    view.render(with: content)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
      view.frame = CGRect(x: 40, y: FrameGuide.statusBarHeight, width: FrameGuide.screenWidth - 80, height: 44)
    }, completion: { finished in
      
    })
    
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
      UIView.animate(withDuration: 0.3, animations: {
        view.alpha = 0
      }, completion: { finished in
        view.removeFromSuperview()
      })
    })
  }
  
}
