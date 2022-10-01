//
//  SearchViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import UIKit

extension SearchType {
  var vc: UIViewController {
    switch self {
    case .users: return UserFollowingViewController(with: .search(""))
    case .repos: return UserStaredReposViewController(userRepoState: .search(""))
    }
  }
}

class SearchViewController: UIViewController {
  
  let types: [SearchType]
  
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.placeholder = "search"
    return searchBar
  }()
  
  lazy var segmentView: UISegmentedControl = {
    let segment = UISegmentedControl(items: ["Users", "Repos"])
    segment.selectedSegmentIndex = 0
    segment.addTarget(self, action: #selector(segmentSelectAction), for: .valueChanged)
    return segment
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.backgroundColor = .backgroundColor
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    scrollView.isPagingEnabled = true
    return scrollView
  }()
  
  lazy var vcs: [UIViewController] = {
    return types.map { $0.vc }
  }()
  
  var currentPage: Int = 0
  var needUpdateScroll = true
  
  init(with types: [SearchType]) {
    self.types = types
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
    view.backgroundColor = .white
    self.navigationItem.titleView = self.searchBar
    
    view.addSubview(self.segmentView)
    self.segmentView.frame = CGRect(
      x: (FrameGuide.screenWidth - 200) / 2,
      y: FrameGuide.navigationBarAndStatusBarHeight + 10 + 12,
      width: 200,
      height: 30
    )
    
    view.addSubview(scrollView)
    let y: CGFloat = self.segmentView.frame.origin.y + self.segmentView.frame.height + 10
    scrollView.frame = CGRect(x: 0, y: y, width: FrameGuide.screenWidth, height: FrameGuide.screenHeight - y)
    for (index, vc) in vcs.enumerated() {
      addChild(vc)
      vc.view.backgroundColor = .red
      scrollView.addSubview(vc.view)
      vc.view.frame = CGRect(x: CGFloat(index) * scrollView.bounds.width, y: 0, width: FrameGuide.screenWidth, height: FrameGuide.screenHeight - y)
    }
    self.scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(vcs.count), height: scrollView.bounds.height)
  }
  
  @objc func segmentSelectAction(segment: UISegmentedControl) {
    self.needUpdateScroll = false
    self.currentPage = segment.selectedSegmentIndex
    self.scrollView.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * FrameGuide.screenWidth, y: scrollView.contentOffset.y), animated: true)
  }
  
}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchText = searchBar.text else { return }
    let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    if let vc = vcs[page] as? UserFollowingViewController {
      vc.type = .search(searchText)
      vc.nextPageState.update(start: 1, hasNext: true, isLoading: false)
      vc.loadData(start: 1)
    }
    if let vc = vcs[page] as? UserStaredReposViewController {
      vc.userRepoState = .search(searchText)
      vc.nextPageState.update(start: 1, hasNext: true, isLoading: false)
      vc.loadNext(start: 1)
    }
  }
}

extension SearchViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetX = scrollView.contentOffset.x
    let page = Int(offsetX / FrameGuide.screenWidth + 0.5)
    if needUpdateScroll && page != self.currentPage {
      self.currentPage = page
      self.segmentView.selectedSegmentIndex = page
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.needUpdateScroll = true
  }
}
