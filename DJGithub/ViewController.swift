//
//  ViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

class ViewController: UIViewController {
  
  var button: UIButton = UIButton()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    button.setTitle("jump", for: .normal)
    button.layer.cornerRadius = 5
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .red
    button.addTarget(self, action: #selector(jumpAction), for: .touchUpInside)
    view.addSubview(button)
    
    button.snp.makeConstraints { make in
      make.center.equalTo(self.view)
      make.width.equalTo(100)
      make.height.equalTo(44)
    }
    
    let barApp = UINavigationBarAppearance()
    barApp.backgroundEffect = UIBlurEffect(style: .regular)
    self.navigationController?.navigationBar.scrollEdgeAppearance = barApp
    
    let indicatorView = IndicatorCookieTerminatorView()
    indicatorView.backgroundColor = .red
    self.view.addSubview(indicatorView)
    
    indicatorView.snp.makeConstraints { make in
      make.leading.equalTo(100)
      make.top.equalTo(200)
      make.width.equalTo(FrameGuide.screenWidth / 5)
      make.height.equalTo(FrameGuide.screenHeight / 7)
    }
    indicatorView.startAnimation()
  }
  
  @objc func jumpAction() {
    self.navigationController?.pushToUserStaredRepo(with: "dyljqq")
  }
}

