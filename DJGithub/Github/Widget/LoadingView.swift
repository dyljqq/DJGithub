//
//  LoadingView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class LoadingView: UIView {

  let defaultSize = CGSize(width: 50, height: 50)

  let size: CGSize

  var lineWidth: CGFloat = 5

  lazy var circleLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    let radius = size.width / 2
    let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: true)
    layer.path = path.cgPath
    layer.lineWidth = lineWidth
    layer.fillColor = nil
    layer.strokeColor = UIColor.gray.cgColor
    layer.lineCap = .round

    return layer
  }()

  lazy var loadingView: UIView = {
    let view = UIView()
    return view
  }()

  init() {
    self.size = defaultSize
    super.init(frame: CGRect.zero)
    setUp()
  }

  init(with size: CGSize) {
    self.size = size
    super.init(frame: CGRect.zero)
    setUp()
  }

  func startAnimation() {
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotationAnimation.fromValue = 0.0
    rotationAnimation.toValue = -Double.pi * 2 // Minus can be Direction
    rotationAnimation.duration = 1
    rotationAnimation.repeatCount = .infinity
    circleLayer.add(rotationAnimation, forKey: "animation")
  }

  func stopAnimation() {
    circleLayer.removeAnimation(forKey: "animation")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    addSubview(loadingView)
    loadingView.layer.addSublayer(circleLayer)

    loadingView.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.size.equalTo(self.size)
    }
  }
}
