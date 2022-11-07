//
//  RssFeedLastestView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/8.
//

import UIKit

class RssFeedLatestView: UIView {
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.text = "Latest Five Feeds:"
    return label
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 300, height: 74)
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 12, left: 10, bottom: 10, right: 12)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .backgroundColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(RssFeedLatestCell.classForCoder(), forCellWithReuseIdentifier: RssFeedLatestCell.className)
    return collectionView
  }()
  
  var didSelectItemClosure: ((Int) -> ())?
  var dataSource: [RssFeedLatestCellModel] = []

  convenience init() {
    self.init(frame: .zero)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  func render(with dataSource: [RssFeedLatestCellModel]) {
    self.dataSource = dataSource
    self.collectionView.reloadData()
  }
  
  private func setUp() {
    addSubview(titleLabel)
    addSubview(collectionView)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.top.equalTo(12)
    }
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension RssFeedLatestView: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RssFeedLatestCell.className, for: indexPath) as! RssFeedLatestCell
    cell.render(with: dataSource[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    didSelectItemClosure?(dataSource[indexPath.row].feedId)
  }
}
