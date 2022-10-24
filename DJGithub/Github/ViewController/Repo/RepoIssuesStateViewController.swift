//
//  RepoIssuesStateViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import UIKit

class RepoIssuesStateViewController: UIViewController {
  
  enum IssueState {
    case issue, pull
    
    var title: String {
      switch self {
      case .pull: return "Pulls"
      case .issue: return "Issues"
      }
    }
  }
  
  let userName: String
  let repoName: String
  let issueState: IssueState
  
  let types: [Issue.IssueState] = [.open, .closed]
  lazy var vcs: [RepoIssuesViewController] = {
    return types.map { RepoIssuesViewController(
      with: self.userName, repoName: self.repoName, issueState: issueState, state: $0) }
  }()
  
  lazy var segmentView: UISegmentedControl = {
    let segment = UISegmentedControl(items: ["Open", "Closed"])
    segment.selectedSegmentIndex = 0
    segment.frame = CGRect(x: 0, y: 100, width: 200, height: 30)
    segment.addTarget(self, action: #selector(segmentSelectAction), for: .valueChanged)
    return segment
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView: UIScrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    return scrollView
  }()
  
  init(userName: String, repoName: String, issueState: IssueState = .issue) {
    self.userName = userName
    self.repoName = repoName
    self.issueState = issueState
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
    configNavigationItem()
  }
  
  private func setUp() {
    view.backgroundColor = .white
    self.navigationItem.title = issueState.title
    
    view.addSubview(segmentView)
    view.addSubview(scrollView)
    segmentView.snp.makeConstraints { make in
      make.top.equalTo(FrameGuide.navigationBarAndStatusBarHeight + 12)
      make.centerX.equalTo(self.view)
      make.width.equalTo(200)
      make.height.equalTo(30)
    }
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(segmentView.snp.bottom).offset(12)
      make.leading.trailing.bottom.equalTo(self.view)
    }
    
    for vc in vcs {
      addChild(vc)
      scrollView.addSubview(vc.view)
    }
  }
  
  private func configNavigationItem() {
    guard issueState != .pull else { return }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(plusAction))
  }
  
  @objc func plusAction() {
    let vc = TitleAndDescViewController(with: .issue(userName: userName, repoName: repoName))
    vc.completionHandler = { [weak self] in
      guard let strongSelf = self else { return }
      let vc = strongSelf.vcs[strongSelf.segmentView.selectedSegmentIndex]
      vc.refresh()
    }
    self.present(vc, animated: true)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    for (index, vc) in vcs.enumerated() {
      vc.view.frame = CGRect(
        x: FrameGuide.screenWidth * CGFloat(index), y: 0, width: FrameGuide.screenWidth, height: scrollView.frame.height)
    }
    self.scrollView.contentSize = CGSize(
      width: FrameGuide.screenWidth * CGFloat(types.count), height: self.scrollView.frame.height)
  }
  
  @objc func segmentSelectAction(segment: UISegmentedControl) {
    let selectedNum = segment.selectedSegmentIndex
    scrollView.setContentOffset(
      CGPoint(x: CGFloat(selectedNum) * scrollView.bounds.width, y: scrollView.contentOffset.y), animated: true)
  }

}

extension RepoIssuesStateViewController: UIScrollViewDelegate {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let offsetX = scrollView.contentOffset.x
    let page = Int(offsetX / scrollView.bounds.width + 0.5)
    self.segmentView.selectedSegmentIndex = page
  }
}
