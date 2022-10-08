//
//  CommitView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/6.
//

import UIKit

class CommitView: UIView {
  
  let content: String
  
  var commitClosure: (() -> ())?
  
  var isLoading: Bool = false {
    didSet {
      update(with: isLoading)
    }
  }
  
  var indicatorView = UIActivityIndicatorView(style: .medium)
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    label.text = content
    return label
  }()
  
  init(with content: String) {
    self.content = content
    super.init(frame: .zero)
    
    setUp()
  }
  
  private func update(with isLoading: Bool) {
    if isLoading {
      self.indicatorView.isHidden = false
      self.contentLabel.isHidden = true
      self.indicatorView.startAnimating()
      self.isUserInteractionEnabled = false
    } else {
      self.indicatorView.isHidden = true
      self.contentLabel.isHidden = false
      self.indicatorView.stopAnimating()
      self.isUserInteractionEnabled = true
    }
  }
  
  private func setUp() {
    self.backgroundColor = .lightBlue
    self.layer.cornerRadius = 5
    self.layer.masksToBounds = true

    addSubview(indicatorView)
    addSubview(contentLabel)
    
    indicatorView.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
    contentLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(commitAction))
    self.addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true
  }
  
  @objc func commitAction() {
    commitClosure?()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
