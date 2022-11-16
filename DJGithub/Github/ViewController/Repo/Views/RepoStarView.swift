//
//  RepoStarView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/26.
//

import UIKit

class RepoStarView: UIView {

  var starClosure: (() -> Void)?

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.isHidden = true
    return indicator
  }()

  lazy var starLabel: UILabel = {
    let label = UILabel()
    return label
  }()

  init() {
    super.init(frame: .zero)

    setUp()
  }

  private func setUp() {
    addSubview(activityIndicator)
    addSubview(starLabel)

    let tap = UITapGestureRecognizer(target: self, action: #selector(starAction))
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(tap)
  }

  func render(with isStar: Bool) {
    let title = isStar ? "unstar" : "star"
    let font = isStar ? UIFont.systemFont(ofSize: 14, weight: .bold) : UIFont.systemFont(ofSize: 14)
    self.starLabel.font = font
    self.starLabel.text = title

    if isStar {
      self.starLabel.textColor = .white
      self.backgroundColor = .blue
    } else {
      self.starLabel.textColor = .blue
      self.backgroundColor = .backgroundColor
    }

    DispatchQueue.global().async {
      let width = NSString(string: title).boundingRect(with: CGSize(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).width
      DispatchQueue.main.async {
        self.frame = CGRect(x: 0, y: 0, width: width + 30, height: 30)
        self.starLabel.frame = CGRect(x: 15, y: 8, width: width, height: 14)
      }
    }
  }

  @objc func starAction() {
    startAnimation()
    starClosure?()
  }

  func startAnimation() {
    self.activityIndicator.center = self.center

    UIView.animate(withDuration: 0.3, animations: {
      self.starLabel.isHidden = true
      self.activityIndicator.isHidden = false
    }, completion: { _ in
      self.activityIndicator.startAnimating()
    })
  }

  func stopAnimation(finishedClosure: @escaping () -> Void) {
    UIView.animate(withDuration: 0.3, animations: {
      self.starLabel.isHidden = false
      self.activityIndicator.isHidden = true
    }, completion: { _ in
      self.activityIndicator.stopAnimating()
      finishedClosure()
    })
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

}
