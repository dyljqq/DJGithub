//
//  IndicatorView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/18.
//

import UIKit

class IndicatorView: RefreshView {

    lazy var arrowLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 0, y: -8))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 5.66, y: 2.34))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: -5.66, y: 2.34))

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.black.withAlphaComponent(0.8).cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        return layer
    }()

  lazy var indicatorCookieterminatorView: IndicatorCookieTerminatorView = {
    return IndicatorCookieTerminatorView(with: 40, tintColor: UIColor.black.withAlphaComponent(0.8))
  }()
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let isHeader: Bool

    init(isHeader: Bool, height: CGFloat, action: @escaping () -> Void) {
      self.isHeader = isHeader
      super.init(refreshPosition: isHeader ? .header : .footer, height: height, action: action)
      layer.addSublayer(arrowLayer)
      arrowLayer.isHidden = true
      
      if isHeader {
        addSubview(indicatorCookieterminatorView)
      } else {
        addSubview(activityIndicator)
      }
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      let center = CGPoint(x: bounds.midX, y: bounds.midY)
      arrowLayer.position = center
      indicatorCookieterminatorView.center = center
      indicatorCookieterminatorView.frame.size = self.bounds.size
      activityIndicator.center = center
    }

    override func didUpdateState(_ isRefreshing: Bool) {
      arrowLayer.isHidden = isRefreshing
      if isHeader {
        isRefreshing ? indicatorCookieterminatorView.startAnimation() : indicatorCookieterminatorView.stopAnimation()
      } else {
        isRefreshing ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
      }
    }

    override func didUpdateProgress(_ progress: CGFloat) {
      self.arrowLayer.isHidden = false
      let rotation = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
      if isHeader {
          arrowLayer.transform = progress == 1 ? rotation : CATransform3DIdentity
      } else {
          arrowLayer.transform = progress == 1 ? CATransform3DIdentity : rotation
      }
    }

}
