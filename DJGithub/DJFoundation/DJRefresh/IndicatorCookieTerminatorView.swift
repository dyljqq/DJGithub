//
//  IndicatorCookieTerminatorView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/18.
//

import UIKit

class IndicatorCookieTerminatorView: UIView {
  
  var animationLayer: CALayer = CALayer()
  
  let size: CGFloat
  var animating = false

  init(with size: CGFloat = 40, tintColor: UIColor = .white) {
    self.size = size
    super.init(frame: .zero)
    
    self.tintColor = tintColor
    setUp()
  }
  
  func startAnimation() {
    if (animationLayer.sublayers != nil) {
      setupAnimation()
    }
    self.isHidden = false
    animationLayer.speed = 1
    animating = true
  }
  
  func stopAnimation() {
    animationLayer.speed = 0
    animating = false
    self.isHidden = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    animationLayer.frame = self.bounds
    if animating {
      stopAnimation()
      setupAnimation()
      startAnimation()
    }
  }
  
  func setupAnimation() {
    animationLayer.sublayers = nil
    setupAnimation(animationLayer, with: CGSize(width: size, height: size), tintColor: tintColor)
    animationLayer.speed = 0
  }
  
  func setupAnimation(_ layer: CALayer, with size: CGSize, tintColor: UIColor) {
    let beginTime = CACurrentMediaTime()
    
    let cookieTerminatorSize = CGFloat(ceilf(Float(size.width) / 3.0))
    let oX = (layer.bounds.size.width - size.width) / 2.0
    let oY = layer.bounds.size.height / 2.0
    let cookieTerminatorCenter = CGPoint(x: oX, y: oY)
    
    var path = UIBezierPath(arcCenter: cookieTerminatorCenter, radius: cookieTerminatorSize, startAngle: Double.pi / 4, endAngle: Double.pi * 1.75, clockwise: true)
    path.addLine(to: cookieTerminatorCenter)
    path.close()
    
    let cookieTerminatorLayer = CAShapeLayer()
    cookieTerminatorLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    cookieTerminatorLayer.fillColor = tintColor.cgColor
    cookieTerminatorLayer.path = path.cgPath
    layer.addSublayer(cookieTerminatorLayer)
    
    path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: cookieTerminatorSize, startAngle: Double.pi / 2, endAngle: Double.pi * 1.5, clockwise: true)
    path.close()
    
    for i in 0..<2 {
      let jawLayer = CAShapeLayer()
      jawLayer.path = path.cgPath
      jawLayer.fillColor = tintColor.cgColor
      jawLayer.position = cookieTerminatorCenter
      jawLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      jawLayer.opacity = 1
      jawLayer.transform = CATransform3DMakeRotation((1.0 - 2.0 * Double(i)) * .pi / 4, 0.0, 0.0, 1.0);

      let transformAnimation = CABasicAnimation(keyPath: "transform")
      transformAnimation.isRemovedOnCompletion = false
      transformAnimation.beginTime = beginTime
      transformAnimation.duration = 0.3
      transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat((1 - 2 * i)) * (.pi / 4), 0, 0, 1))
      transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat((1 - 2 * i)) * (.pi / 2), 0, 0, 1))
      transformAnimation.autoreverses = true
      transformAnimation.repeatCount = .infinity
      transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      layer.addSublayer(jawLayer)
      jawLayer.add(transformAnimation, forKey: "cookieTerminatorAnimation")
    }
    
    let cookieSize = CGFloat(ceilf(Float(size.width) / 6))
    let cookiePadding = cookieSize * 2
    for i in 0..<3 {
      let cookieLayer = CALayer()
      cookieLayer.frame = CGRect(x: cookieTerminatorCenter.x + (cookieSize + cookiePadding) * 3 - cookieTerminatorSize, y: oY - cookieSize, width: cookieSize, height: cookieSize)
      cookieLayer.backgroundColor = tintColor.cgColor
      cookieLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      cookieLayer.opacity = 1
      cookieLayer.cornerRadius = cookieSize / 2
      
      let transformAnimation = CABasicAnimation(keyPath: "transform")
      transformAnimation.duration = 1.8
      transformAnimation.beginTime = beginTime - (CGFloat(i) * transformAnimation.duration / 3)
      transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0))
      transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeTranslation(-3 * (cookieSize + cookiePadding), 0, 0))
      transformAnimation.repeatCount = .infinity
      transformAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
      
      layer.addSublayer(cookieLayer)
      cookieLayer.add(transformAnimation, forKey: "cookieAnimation")
    }
  }
  
  private func setUp() {
    self.isUserInteractionEnabled = false
    self.isHidden = true
    self.layer.addSublayer(self.animationLayer)
  }
  
  required init?(coder: NSCoder) {
    self.size = 40
    super.init(coder: coder)
  }
  
}
