//
//  RepoInteractViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import UIKit

class RepoInteractViewController: UIViewController {

  enum RepoInteractType {
    case watches(String)
    case contributor(String)
    case star(String)
    case forks(String)
    
    var title: String {
      switch self {
      case .watches: return "Watches"
      case .contributor: return "Contributors"
      case .star: return "Stargazers"
      case .forks: return "Forks"
      }
    }
    
    var userFollowingType: UserFollowingType {
      switch self {
      case .watches(let name): return UserFollowingType.watches(name)
      case .contributor(let name): return UserFollowingType.contributor(name)
      case .star(let name): return UserFollowingType.star(name)
      default: return UserFollowingType.unknown
      }
    }
  }
  
  let repoName: String
  var repo: Repo?
  var selectedIndex: Int = 0 {
    didSet {
      self.scrollView.setContentOffset(
        CGPoint(x: self.scrollView.frame.width * CGFloat(selectedIndex), y: 0), animated: true)
      self.headerSegmentView.selectedIndex = selectedIndex
    }
  }
  
  let initType: RepoInteractType
  
  lazy var vcs: [UIViewController] = {
    return types.map { type in
      if case RepoInteractType.forks(let name) = type {
        return UserStaredReposViewController(with: UserRepoState.fork(name), repo: self.repo)
      } else {
        return UserFollowingViewController(with: type.userFollowingType)
      }
    }
  }()
  
  lazy var headerSegmentView: HeaderSegmentView = {
    let arr: [String] = types.map { $0.title }
    let headerView = HeaderSegmentView(with: arr, selectedIndex: 0)
    return headerView
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.bounces = false
    return scrollView
  }()
  
  lazy var types: [RepoInteractType] = {
    return [
      .watches(repoName),
      .star(repoName),
      .forks(repoName),
      .contributor(repoName)
    ]
  }()
  
  init(with repoName: String) {
    self.repoName = repoName
    self.initType = .watches(repoName)
    super.init(nibName: nil, bundle: nil)
  }
  
  init(with type: RepoInteractType) {
    self.initType = type
    switch type {
    case .watches(let repoName), .star(let repoName), .contributor(let repoName), .forks(let repoName):
      self.repoName = repoName
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  private func setUp() {
    self.navigationItem.title = self.repo?.name ?? repoName

    view.backgroundColor = .white
    view.addSubview(headerSegmentView)
    view.addSubview(scrollView)
    
    headerSegmentView.frame = CGRect(
      x: 0, y: FrameGuide.navigationBarAndStatusBarHeight, width: FrameGuide.screenWidth, height: 44)
    scrollView.frame = CGRect(
      x: 0, y: headerSegmentView.frame.maxY, width: FrameGuide.screenWidth, height: FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight)
    
    for vc in vcs {
      addChild(vc)
      scrollView.addSubview(vc.view)
    }
    
    headerSegmentView.selectedClosure = { [weak self] index in
      guard let strongSelf = self else { return }
      strongSelf.scrollView.setContentOffset(
        CGPoint(x: strongSelf.scrollView.frame.width * CGFloat(index), y: 0), animated: true)
    }
    
    var flag = false
    for (index, typ) in types.enumerated() {
      switch (typ, self.initType) {
      case (.watches(let n1), .watches(let n2)) where n1 == n2,
        (.forks(let n1), .forks(let n2)) where n1 == n2,
        (.contributor(let n1), .contributor(let n2)) where n1 == n2,
        (.star(let n1), .star(let n2)) where n1 == n2:
        flag = true
      default:
        flag = false
      }
      
      if flag {
        self.selectedIndex = index
        break
      }
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    for (index, vc) in vcs.enumerated() {
      vc.view.frame = CGRect(x: FrameGuide.screenWidth * CGFloat(index), y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
    }
    scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(vcs.count), height: scrollView.frame.height)
  }

}

extension RepoInteractViewController: UIScrollViewDelegate {  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
    if page != self.headerSegmentView.selectedIndex {
      self.headerSegmentView.selectedIndex = page
    }
  }
}
