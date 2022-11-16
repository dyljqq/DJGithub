//
//  HeaderSegmentView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class HeaderSegmentCell: UICollectionViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textColor = .lightBlue
    return label
  }()

  lazy var indicatorLineView: UIView = {
    let view = UIView()
    view.backgroundColor = .lightBlue
    view.layer.cornerRadius = 2
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setUp()
  }

  func render(with model: HeaderSegmentView.HeaderModel) {
    titleLabel.text = model.title
    self.indicatorLineView.isHidden = !model.selected
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(indicatorLineView)

    titleLabel.snp.makeConstraints { make in
      make.center.equalTo(self.contentView)
    }
    indicatorLineView.snp.makeConstraints { make in
      make.centerX.equalTo(self.contentView)
      make.bottom.equalTo(self.contentView)
      make.height.equalTo(4)
      make.width.equalTo(30)
    }
  }

}

class HeaderSegmentView: UIView {

  struct HeaderModel {
    var title: String

    var width: CGFloat = 0
    var selected: Bool = false

    init(title: String, width: CGFloat = 0, selected: Bool = false) {
      self.title = title
      self.width = width
      self.selected = selected
    }
  }

  var selectedClosure: ((Int) -> Void)?

  lazy var layout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.scrollDirection = .horizontal
    return layout
  }()

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(HeaderSegmentCell.classForCoder(), forCellWithReuseIdentifier: HeaderSegmentCell.className)
    return collectionView
  }()

  let items: [String]
  var selectedIndex: Int = 0 {
    didSet {
      self.update(selectedIndex: self.selectedIndex)
    }
  }
  var dataSource: [HeaderModel] = []

  init(with items: [String], selectedIndex: Int = 0) {
    self.items = items
    super.init(frame: .zero)

    self.selectedIndex = selectedIndex
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    self.backgroundColor = .white
    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.bottom.centerX.equalTo(self)
      make.width.equalTo(FrameGuide.screenWidth)
    }

    var totalWidth: CGFloat = 0
    DispatchQueue.global().async {
      for (index, item) in self.items.enumerated() {
        let width = (item as NSString).boundingRect(
          with: CGSize(width: 0, height: 14),
          options: .usesLineFragmentOrigin,
          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)],
          context: nil).size.width + 30
        self.dataSource.append(HeaderModel(title: item, width: width, selected: index == self.selectedIndex))
        totalWidth += width
      }
      DispatchQueue.main.async {
        if totalWidth < FrameGuide.screenWidth {
          self.collectionView.snp.updateConstraints { make in
            make.width.equalTo(totalWidth)
          }
        }
        self.collectionView.reloadData()
      }
    }
  }

  fileprivate func update(selectedIndex: Int) {
    self.dataSource = self.dataSource.enumerated().map { (index, model) in
      return HeaderModel(title: model.title, width: model.width, selected: index == selectedIndex)
    }
    self.collectionView.reloadData()
    self.collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0),
                                     at: .centeredHorizontally, animated: true)
  }

}

extension HeaderSegmentView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderSegmentCell.className, for: indexPath) as! HeaderSegmentCell
    cell.render(with: self.dataSource[indexPath.row])
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let model = self.dataSource[indexPath.row]
    return CGSize(width: model.width, height: collectionView.frame.height)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    self.selectedIndex = indexPath.row
    selectedClosure?(indexPath.row)
  }

}
