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

  var defaultBranchName: String = "master"

  var branches: [RepoBranch] = []

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

    NotificationCenter.default.addObserver(forName: NotificationKeys.createPullRequestKey, object: nil, queue: .main) { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.refreshNotification(with: 0)
    }
    NotificationCenter.default.addObserver(forName: NotificationKeys.closePullRequestKey, object: nil, queue: .main) { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.refreshNotification(with: 1)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUp()
    configNavigationItem()
    Task {
      self.branches = await RepoManager.fetchRepoBranches(with: userName, repoName: repoName, params: [:])
    }
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
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(plusAction))
  }

  @objc func plusAction() {
    switch issueState {
    case .pull:
      showBranches()
    case .issue:
      let vc = TitleAndDescViewController(with: .issue(userName: userName, repoName: repoName))
      vc.completionHandler = { [weak self] in
        guard let strongSelf = self else { return }
        let vc = strongSelf.vcs[strongSelf.segmentView.selectedSegmentIndex]
        vc.refresh()
      }
      self.present(vc, animated: true)
    }
  }

  private func showBranches() {
    Task {
      if self.branches.isEmpty {
        self.branches = await RepoManager.fetchRepoBranches(with: userName, repoName: repoName, params: [:])
      }
      guard !self.branches.isEmpty else { return }
      let branchListView = RepoBranchListView()
      branchListView.showCheckIcon = false
      let config = DJMaskContentConfig(view: branchListView, size: CGSize(width: 300, height: 300))
      let maskView = DJMaskView.show(with: config)
      config.render(with: self.branches, title: "New pull request")
      branchListView.selectedClosure = { [weak self] branch in
        guard let strongSelf = self else { return }
        maskView?.hide {
          strongSelf.navigationController?.pushToRepoBranchCommit(
            with: strongSelf.defaultBranchName,
            head: branch.name,
            urlString: branch.commit.url,
            showCommitButton: true
          )
        }
      }
    }
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

  private func refreshNotification(with index: Int) {
    guard index >= 0 && index < vcs.count else { return }
    segmentView.selectedSegmentIndex = index
    scrollView.setContentOffset(
      CGPoint(x: CGFloat(index) * FrameGuide.screenWidth, y: scrollView.contentOffset.y), animated: true)
    vcs[index].refresh()
  }

}

extension RepoIssuesStateViewController: UIScrollViewDelegate {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let offsetX = scrollView.contentOffset.x
    let page = Int(offsetX / scrollView.bounds.width + 0.5)
    self.segmentView.selectedSegmentIndex = page
  }
}
