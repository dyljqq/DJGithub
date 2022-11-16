//
//  DevelopersViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import UIKit

class DevelopersViewController: UIViewController {

  var isSelectedSegment = false

  lazy var segmentView: UISegmentedControl = {
    let segment = UISegmentedControl(items: ["Repos", "Feeds", "Developers"])
    segment.selectedSegmentIndex = 0
    segment.frame = CGRect(x: 0, y: 100, width: 240, height: 30)
    segment.addTarget(self, action: #selector(segmentSelectAction), for: .valueChanged)
    return segment
  }()

  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.backgroundColor = .backgroundColor
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bounces = false
    scrollView.isPagingEnabled = true
    return scrollView
  }()

  lazy var vcs: [UIViewController] =  {
    return [
      LocalDevelopersViewController(with: .repo),
      FeedsViewController(),
      LocalDevelopersViewController(with: .developer)
    ]
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .backgroundColor
    self.navigationItem.titleView = segmentView

    view.addSubview(scrollView)
    scrollView.frame = CGRect(
      x: 0,
      y: FrameGuide.navigationBarAndStatusBarHeight,
      width: FrameGuide.screenWidth,
      height: FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight - FrameGuide.tabbarHeight
    )

    for (_, vc) in vcs.enumerated() {
      addChild(vc)
      scrollView.addSubview(vc.view)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.contentSize = CGSize(width: FrameGuide.screenWidth * CGFloat(vcs.count), height: scrollView.bounds.height)
    for (index, vc) in vcs.enumerated() {
      var frame = scrollView.frame
      frame.origin = CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0)
      vc.view.frame = frame
    }
  }

  @objc func segmentSelectAction(segment: UISegmentedControl) {
    isSelectedSegment = true
    let selectedNum = segment.selectedSegmentIndex
    scrollView.setContentOffset(
      CGPoint(x: CGFloat(selectedNum) * scrollView.bounds.width, y: scrollView.contentOffset.y), animated: true)
  }

}

extension DevelopersViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isSelectedSegment = false
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard !isSelectedSegment else { return }
    let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
    self.segmentView.selectedSegmentIndex = page
  }
}
