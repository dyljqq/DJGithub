//
//  UserStatusView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import UIKit

class UserStatusView: UIView {
  
  enum UserStatusType {
    case active
    case inactive
    case loading
  }
  
  enum LayoutWay {
    case normal
    case auto
  }
  
  let layoutWay: LayoutWay
  
  var height: CGFloat = 30
  
  var touchClosure: (() -> ())?
  
  var contentLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  var activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    return activityIndicatorView
  }()
  
  init(layoutLay: LayoutWay = .auto) {
    layoutWay = layoutLay
    super.init(frame: .zero)
    setUp()
  }
  
  func render(with statusType: UserStatusType, content: String = "", widthClosure: ((CGFloat) -> ())? = nil) {
    if case .loading = statusType {
      activityIndicatorView.isHidden = false
      activityIndicatorView.startAnimating()
      contentLabel.isHidden = true
      return
    }
    
    activityIndicatorView.stopAnimating()
    activityIndicatorView.isHidden = true
    contentLabel.isHidden = false
    contentLabel.text = content
    
    let font: UIFont?
    var fontSize: CGFloat = 14
    switch statusType {
    case .active:
      font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
      contentLabel.textColor = .white
      backgroundColor = .lightBlue
    case .inactive:
      fontSize = 12
      font = UIFont.systemFont(ofSize: fontSize)
      contentLabel.textColor = .blue
      backgroundColor = .backgroundColor
    default:
      font = nil
      break
    }
    
    if let font = font {
      contentLabel.font = font
      DispatchQueue.global().async {
        let width = (content as NSString).boundingRect(with: CGSize(width: 0, height: 14), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size.width
        DispatchQueue.main.async {
          if case .normal = self.layoutWay {
            self.frame = CGRect(x: 0, y: 0, width: width + 30, height: self.height)
            self.activityIndicatorView.center = self.center
            self.contentLabel.frame = CGRect(x: 15, y: (self.height - fontSize) / 2, width: width, height: fontSize)
          }
          widthClosure?(width + 30)
        }
      }
    }
  }
  
  private func setUp() {
    addSubview(contentLabel)
    addSubview(activityIndicatorView)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(touchAction))
    addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true
    
    updateLayout()
  }
  
  func updateLayout() {
    switch layoutWay {
    case .auto:
      contentLabel.snp.makeConstraints { make in
        make.center.equalTo(self)
      }
      activityIndicatorView.snp.makeConstraints { make in
        make.center.equalTo(self)
      }
    case .normal:
      self.frame = CGRect(x: 0, y: 0, width: 0, height: height)
    }
  }
  
  @objc func touchAction() {
    touchClosure?()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
