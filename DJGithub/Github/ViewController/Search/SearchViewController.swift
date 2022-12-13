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
    case .users: return UserFollowingViewController(with: .search(SearchCondition(query: "")))
    case .repos: return UserStaredReposViewController(userRepoState: .search(SearchCondition(query: "")))
    }
  }
}

class SearchViewController: UIViewController {

  enum SearchViewType {
    case history
    case result
  }

  struct Constants {
    static let startIndex = 1
  }

  let types: [SearchType]

  var sortedParam: String = ""

  var searchType: SearchType {
    return types[currentPage]
  }

  var filterParams: [String] {
    switch searchType {
    case .users:
      return ["followers", "repositories"]
    case .repos:
      return ["stars", "forks", "updated"]
    }
  }

  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.placeholder = "search"
    searchBar.searchTextField.clearsOnBeginEditing = true
    return searchBar
  }()

  lazy var segmentView: UISegmentedControl = {
    let segment = UISegmentedControl(items: ["Users", "Repos"])
    segment.selectedSegmentIndex = 0
    segment.addTarget(self, action: #selector(segmentSelectAction), for: .valueChanged)
    return segment
  }()

  lazy var searchSortedImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "search_sort")

    let tap = UITapGestureRecognizer(target: self, action: #selector(filterAction))
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(tap)

    return imageView
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

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.rowHeight = 44
    tableView.backgroundColor = .white
    tableView.tableHeaderView = self.headerView
    tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.className)
    return tableView
  }()

  lazy var headerView: SearchWordHeaderView = {
    let view = SearchWordHeaderView()
    view.frame = CGRect(x: 0, y: 0, width: FrameGuide.screenWidth, height: 44)
    return view
  }()

  lazy var vcs: [UIViewController] = {
    return types.map { $0.vc }
  }()

  var historyWords: [String] {
    return SearchWordManager.shared.load()
  }

  var currentPage: Int = 0
  var needUpdateScroll = true
  var searchWord: String = ""
  var historyPanToken: NSKeyValueObservation?
  var resultPanTokens: [NSKeyValueObservation?] = []

  var searchViewType: SearchViewType = .history {
    didSet {
      self.update(with: searchViewType)
    }
  }

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
    addObserver()
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
    view.addSubview(searchSortedImageView)
    searchSortedImageView.snp.makeConstraints { make in
      make.centerY.equalTo(FrameGuide.navigationBarAndStatusBarHeight + 37)
      make.trailing.equalToSuperview().offset(-12)
      make.width.height.equalTo(18)
    }

    view.addSubview(self.tableView)
    self.tableView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentView.snp.bottom)
      make.bottom.leading.trailing.equalTo(self.view)
    }

    self.headerView.eraseClosure = { [weak self] in
      SearchWordManager.shared.removeAll()
      self?.tableView.reloadData()
    }

    scrollView.isHidden = true
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

  private func addObserver() {
    historyPanToken = tableView.observe(\.panGestureRecognizer.state) { [weak self] _, _ in
      self?.searchBar.searchTextField.resignFirstResponder()
    }

    for vc in vcs {
      if let vc = vc as? UserStaredReposViewController {
        let token = vc.tableView.observe(\.panGestureRecognizer.state) { [weak self] (_, _) in
          self?.searchBar.searchTextField.resignFirstResponder()
        }
        resultPanTokens.append(token)
      } else if let vc = vc as? UserFollowingViewController {
        let token = vc.tableView.observe(\.panGestureRecognizer.state) { [weak self] (_, _) in
          self?.searchBar.searchTextField.resignFirstResponder()
        }
        resultPanTokens.append(token)
      }
    }
  }

  private func clearObserver() {
    historyPanToken?.invalidate()
    for token in resultPanTokens {
      token?.invalidate()
    }
  }

  @objc func segmentSelectAction(segment: UISegmentedControl) {
    self.needUpdateScroll = false
    self.currentPage = segment.selectedSegmentIndex
    self.scrollView.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * FrameGuide.screenWidth, y: scrollView.contentOffset.y), animated: true)
  }

  @objc func filterAction() {
    let sheetVC = UIAlertController(title: "Sorted Condition", message: "", preferredStyle: .actionSheet)
    for param in filterParams {
      sheetVC.addAction(UIAlertAction(title: param, style: .default) { [weak self] _ in
        guard let strongSelf = self else { return }
        strongSelf.sortedParam = param
        strongSelf.loadData(with: Constants.startIndex)
      })
    }
    sheetVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(sheetVC, animated: true)
  }

  private func update(with type: SearchViewType) {
    switch type {
    case .history:
      self.scrollView.isHidden = true
      self.tableView.isHidden = false
      self.tableView.reloadData()
    case .result:
      self.scrollView.isHidden = false
      self.tableView.isHidden = true
      self.loadData(with: self.currentPage)
    }
  }

  func loadData(with page: Int) {
    guard !self.searchWord.isEmpty else {
      return
    }

    for vc in vcs {
      let condition = SearchCondition(query: searchWord, sort: sortedParam)
      if let vc = vc as? UserFollowingViewController {
        vc.type = .search(condition)
        vc.nextPageState.update(start: Constants.startIndex, hasNext: true, isLoading: false)
        vc.loadData(start: Constants.startIndex)
      } else if let vc = vc as? UserStaredReposViewController {
        vc.userRepoState = .search(condition)
        vc.nextPageState.update(start: Constants.startIndex, hasNext: true, isLoading: false)
        vc.loadNext(start: Constants.startIndex)
      }
    }
  }

  deinit {
    self.clearObserver()
  }

}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      self.searchWord = ""
      self.update(with: .history)
    }
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchText = searchBar.text else { return }
    self.searchWord = searchText
    self.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    if searchText.isEmpty {
      self.update(with: .history)
    } else {
      self.update(with: .result)
      SearchWordManager.shared.save(with: searchText)
    }
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.searchBar.searchTextField.text = self.searchWord
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return historyWords.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = self.historyWords[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    self.searchWord = self.historyWords[indexPath.row]
    self.searchBar.text = self.searchWord
    self.update(with: .result)
    SearchWordManager.shared.move(index: indexPath.row, to: 0)
  }
}
