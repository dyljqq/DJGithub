//
//  PinnedItemsCell.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/26.
//

import UIKit

class PinnedItemsCell: UITableViewCell {

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 10
    layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    layout.scrollDirection = .horizontal

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(PinnedRepoCell.classForCoder(), forCellWithReuseIdentifier: PinnedRepoCell.className)
    return collectionView
  }()

  var dataSource: [PinnedRepoNode] = []
  var onTouchPinnedItem: ((PinnedRepoNode) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    collectionView.backgroundColor = .backgroundColor
    contentView.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func render(with pinnedItem: PinnedRepos) {
    self.dataSource = pinnedItem.nodes
    self.collectionView.reloadData()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension PinnedItemsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinnedRepoCell.className, for: indexPath) as! PinnedRepoCell
    cell.render(with: dataSource[indexPath.row])
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 300, height: 110)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    onTouchPinnedItem?(dataSource[indexPath.row])
  }
}
