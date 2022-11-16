//
//  UserContributionView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

class UserContributionView: UIView {

  lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: 10, height: 10)
    flowLayout.minimumLineSpacing = 2
    flowLayout.minimumInteritemSpacing = 2
    flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    flowLayout.scrollDirection = .horizontal

    let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(UserContrbutionItemCell.classForCoder(), forCellWithReuseIdentifier: UserContrbutionItemCell.className)
    return collectionView
  }()

  var userContribution: UserContribution?

  init() {
    super.init(frame: CGRect.zero)

    setUp()
  }

  init(with userContribution: UserContribution) {
    self.userContribution = userContribution
    super.init(frame: CGRect.zero)

    setUp()
  }

  func render(with userContribution: UserContribution) {
    self.userContribution = userContribution
    self.collectionView.reloadData()

    self.collectionView.performBatchUpdates(nil) { [weak self] _ in
      guard let strongSelf = self else {
        return
      }
      strongSelf.collectionView.scrollToItem(at: IndexPath(row: userContribution.items.count - 1, section: 0), at: .centeredHorizontally, animated: true)
    }
  }

  func setUp() {
    backgroundColor = .white

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }

  override init(frame: CGRect) {
    self.userContribution = nil
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    self.userContribution = nil
    super.init(coder: coder)
  }

}

extension UserContributionView: UICollectionViewDelegate {

}

extension UserContributionView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userContribution?.items.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserContrbutionItemCell.className, for: indexPath) as! UserContrbutionItemCell
    if let userContribution = userContribution {
      cell.render(with: userContribution.items[indexPath.row])
    }
    return cell
  }
}

extension UserContributionView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    let attributes = collectionView.layoutAttributesForItem(at: indexPath)
    if let frame = attributes?.frame, let userContribution = userContribution?.items[indexPath.row] {
      let popoverView = PopoverView(content: userContribution.contributionDesc)
      popoverView.showPopover(in: CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: FrameGuide.screenHeight), sourceRect: self.convert(collectionView.convert(frame, to: self), to: UIApplication.shared.keyWindow))
    }
  }
}
