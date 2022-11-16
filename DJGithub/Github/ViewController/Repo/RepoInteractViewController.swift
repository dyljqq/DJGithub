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
    case repositories(String)
    case followers(String)
    case following(String)
    case userWatches(String)
    case userStar(String)

    var title: String {
      switch self {
      case .watches: return "Watches"
      case .contributor: return "Contributors"
      case .star: return "Stargazers"
      case .forks: return "Forks"
      case .followers: return "Followers"
      case .following: return "Following"
      case .repositories: return "Repositories"
      case .userWatches: return "Watches"
      case .userStar: return "Stars"
      }
    }

    var userFollowingType: UserFollowingType {
      switch self {
      case .watches(let name): return UserFollowingType.watches(name)
      case .contributor(let name): return UserFollowingType.contributor(name)
      case .star(let name): return UserFollowingType.star(name)
      case .following(let name): return UserFollowingType.following(name)
      case .followers(let name): return UserFollowingType.followers(name)
      default: return UserFollowingType.unknown
      }
    }

    var userRepoState: UserRepoState {
      switch self {
      case .forks(let name): return UserRepoState.fork(name)
      case .repositories(let name): return UserRepoState.repos(name)
      case .userStar(let name): return UserRepoState.star(name)
      case .userWatches(let name): return UserRepoState.subscription(name)
      default: return .unknown
      }
    }
  }

  var selectedIndex: Int = 0 {
    didSet {
      self.update(with: selectedIndex)
    }
  }

  lazy var vcs: [UIViewController] = {
    return types.map { type in
      switch type {
      case .watches, .star, .contributor, .following, .followers:
        return UserFollowingViewController(with: type.userFollowingType)
      case .repositories, .userStar, .forks, .userWatches:
        return UserStaredReposViewController(userRepoState: type.userRepoState)
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

  let types: [RepoInteractType]
  let interactTitle: String
  var needUpdateHeader: Bool = true

  init(with types: [RepoInteractType], title: String = "", selectedIndex: Int = 0) {
    self.types = types
    self.interactTitle = title
    self.selectedIndex = selectedIndex
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
    self.navigationItem.title = interactTitle

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
      strongSelf.needUpdateHeader = false
      strongSelf.scrollView.setContentOffset(
        CGPoint(x: strongSelf.scrollView.frame.width * CGFloat(index), y: 0), animated: true)
    }

    update(with: self.selectedIndex)
  }

  private func update(with index: Int) {
    self.scrollView.setContentOffset(
      CGPoint(x: self.scrollView.frame.width * CGFloat(index), y: 0), animated: true)
    self.headerSegmentView.selectedIndex = index
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
    if needUpdateHeader && page != self.headerSegmentView.selectedIndex {
      self.headerSegmentView.selectedIndex = page
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    needUpdateHeader = true
  }
}
