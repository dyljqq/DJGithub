//
//  SearchWordHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/3.
//

import UIKit

class SearchWordHeaderView: UIView {

  var eraseClosure: (() -> Void)?

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "History search words"
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()

  lazy var eraseImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = ImageDecoder.downsampledImage(
      data: UIImage(named: "icons-erase")!.pngData()!, to: CGSize(width: 25, height: 25), scale: 1)
    imageView.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(eraseAction))
    imageView.addGestureRecognizer(tap)
    return imageView
  }()

  init() {
    super.init(frame: .zero)

    setUp()
  }

  @objc func eraseAction() {
    eraseClosure?()
  }

  private func setUp() {
    addSubview(titleLabel)
    addSubview(eraseImageView)
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self)
      make.leading.equalTo(12)
    }
    eraseImageView.snp.makeConstraints { make in
      make.centerY.equalTo(self)
      make.trailing.equalTo(-13)
      make.width.height.equalTo(25)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
