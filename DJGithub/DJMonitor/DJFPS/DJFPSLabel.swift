//
//  DJFPSLabel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import UIKit

class DJFPSLabel: UILabel {

  var count = 0
  var link: CADisplayLink?
  var lastTime: TimeInterval = 0

  convenience init() {
    self.init(frame: .zero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUp()
  }

  private func setUp() {

    layer.cornerRadius = 5
    clipsToBounds = true
    textAlignment = .center
    isUserInteractionEnabled = false
    backgroundColor = UIColor.black.withAlphaComponent(0.7)
    font = UIFont.systemFont(ofSize: 14)

    link = CADisplayLink(target: self, selector: #selector(tick))
    link?.add(to: .main, forMode: .common)
  }

  @objc func tick() {
    guard let link = self.link else { return }
    guard lastTime > 0 else {
      lastTime = link.timestamp
      return
    }
    count = count + 1
    let delta = link.timestamp - lastTime
    if delta < 1 { return }
    lastTime = link.timestamp
    let fps = CGFloat(count) / CGFloat(delta)
    count = 0

    let progress = fps / 60
    let color = UIColor(hue: 0.27 * (progress - 0.2), saturation: 1, brightness: 0.9, alpha: 1)
    let text = "\(Int(fps)) FPS"
    let attr = NSMutableAttributedString(string: text)
    attr.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count - 3))
    attr.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: text.count - 3, length: 3))
    self.attributedText = attr
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: 55, height: 20)
  }

  deinit {
    link?.invalidate()
  }
}
