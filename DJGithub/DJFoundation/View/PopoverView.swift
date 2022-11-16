//
//  PopoverView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/19.
//

import UIKit

class PopoverView: UIView {

  enum PopoverDirection {
    case up, down
  }

  var cornerRadius: CGFloat = 5

  lazy var contentView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.15
    view.layer.shadowRadius = 15
    view.layer.cornerRadius = 5
    view.layer.shadowOffset = CGSize(width: 5, height: 5)
    return view
  }()

  var content: String = ""

  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
    label.text = content
    return label
  }()

  init(content: String) {
    self.content = content
    super.init(frame: .zero)
    setUp()
  }

  func showPopover(in rect: CGRect, sourceRect: CGRect) {
    let sourceViewInWindowFrame = sourceRect
    let interval: CGFloat = 2
    contentView.frame.size = CGSize(width: FrameGuide.screenWidth - interval * 2, height: 44)

    let x = sourceViewInWindowFrame.origin.x + sourceViewInWindowFrame.size.width / 2
    let y = sourceViewInWindowFrame.origin.y + sourceViewInWindowFrame.size.height / 2

    let direction = PopoverDirection.down
    var point = CGPoint.zero
    switch direction {
    case .down:
      point = CGPoint(
        x: x, y: y - contentView.bounds.height / 2 - CGFloat(interval) - sourceViewInWindowFrame.size.height / 2)
    default:
      break
    }
    contentView.frame.origin.x = interval
    contentView.center = CGPoint(x: interval + contentView.frame.width / 2, y: point.y)

    if contentView.frame.origin.y < rect.origin.y {
      contentView.frame.origin.y = rect.origin.y + interval
    }
    if (contentView.frame.origin.y + contentView.bounds.size.height) > (rect.origin.y + rect.size.height) {
      contentView.frame.origin.y = rect.origin.y + rect.size.height - interval - contentView.bounds.size.height
    }

    alpha = 0
    UIView.animate(withDuration: 0.3, animations: {
      self.alpha = 1
    })

    let triangleSize = CGSize(width: 20, height: 8)
    createPopoverLayer(
      triangleOrigin: CGPoint(x: point.x - contentView.frame.origin.x - triangleSize.width / 2,
                              y: contentView.frame.size.height), triangleSize: triangleSize)
  }

  func createPopoverLayer(triangleOrigin: CGPoint, triangleSize: CGSize) {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: cornerRadius, y: 0))
    path.addLine(to: CGPoint(x: contentView.frame.size.width - cornerRadius, y: 0))
    path.addArc(
      withCenter: CGPoint(x: contentView.frame.size.width - cornerRadius, y: cornerRadius),
      radius: cornerRadius,
      startAngle: -.pi / 2,
      endAngle: 0, clockwise: true
    )
    if (triangleOrigin.x + triangleSize.width) >=
        (contentView.frame.origin.x + contentView.frame.size.width - cornerRadius) {
      path.addLine(to: CGPoint(x: contentView.frame.size.width, y: contentView.frame.size.height))
      path.addLine(
        to: CGPoint(
          x: contentView.frame.size.width - triangleSize.width / 2,
          y: contentView.frame.size.height + triangleSize.height)
      )
      path.addLine(to: CGPoint(x: contentView.frame.size.width - triangleSize.width, y: contentView.frame.height))
    } else {
      path.addLine(to: CGPoint(x: contentView.frame.size.width, y: contentView.frame.size.height - cornerRadius))
      path.addArc(
        withCenter: CGPoint(x: contentView.frame.size.width - cornerRadius,
                            y: contentView.frame.size.height - cornerRadius),
        radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
      path.addLine(to: CGPoint(x: triangleOrigin.x + triangleSize.width, y: contentView.frame.height))
      path.addLine(
        to: CGPoint(x: triangleOrigin.x + triangleSize.width / 2,
                    y: contentView.frame.height + triangleSize.height))
      path.addLine(to: CGPoint(x: triangleOrigin.x, y: contentView.frame.size.height))
    }
    path.addLine(to: CGPoint(x: cornerRadius, y: contentView.frame.size.height))
    path.addArc(
      withCenter: CGPoint(x: cornerRadius, y: contentView.frame.size.height - cornerRadius),
      radius: cornerRadius,
      startAngle: .pi / 2,
      endAngle: .pi,
      clockwise: true
    )
    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
    path.addArc(
      withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
      radius: cornerRadius,
      startAngle: .pi,
      endAngle: 1.5 * .pi,
      clockwise: true
    )

    let layer = CAShapeLayer()
    layer.path = path.cgPath
    layer.fillColor = UIColor.black.cgColor
    contentView.layer.insertSublayer(layer, at: 0)
  }

  func hide() {
    UIView.animate(withDuration: 0.3, animations: {
      self.alpha = 1
    }, completion: { _ in
      self.removeFromSuperview()
    })
  }

  private func setUp() {
    guard let window = UIApplication.shared.keyWindow else {
      return
    }
    frame = window.bounds
    window.addSubview(self)
    backgroundColor = .clear

    let tap = UITapGestureRecognizer(target: self, action: #selector(hideAction))
    addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true

    addSubview(contentView)
    contentView.addSubview(contentLabel)

    contentLabel.snp.makeConstraints { make in
      make.center.equalTo(contentView)
      make.leading.equalTo(12)
      make.trailing.equalTo(12)
    }
  }

  @objc func hideAction() {
    hide()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

}
