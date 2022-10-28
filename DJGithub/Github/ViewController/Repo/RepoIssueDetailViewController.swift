//
//  RepoIssueDetailViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/5.
//

import UIKit
import MarkdownView

extension Issue.IssueState {
  var color: UIColor {
    switch self {
    case .open: return .green
    case.closed: return .red
    }
  }
}

class RepoIssueDetailHeaderView: UIView {
  
  var issue: IssueDetail?
  
  var touchedTitleClosure: (() -> ())?
  var updateStateClosure:(() -> ())?
  
  lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .blue
    label.numberOfLines = 0
    return label
  }()
  
  lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  lazy var stateLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .green
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.layer.cornerRadius = 12
    label.layer.masksToBounds = true
    label.textAlignment = .center
    label.isUserInteractionEnabled = true
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(updateStateAction))
    label.addGestureRecognizer(tap)
    
    return label
  }()
  
  init() {
    super.init(frame: .zero)
    
    setUp()
  }
  
  func render(with issue: IssueDetail, comletionHandler: ((CGFloat) -> ())? = nil) {
    self.issue = issue
    titleLabel.text = "\(issue.title) - #\(issue.number)"
    avatarImageView.setImage(with: URL(string: issue.user.avatarUrl))
    if let date = issue.createdAt.components(separatedBy: "T").first {
      contentLabel.text = "\(issue.user.login) commented on \(date)"
    } else {
      contentLabel.text = "\(issue.user.login) commented on \(issue.createdAt)"
    }
    
    let text = issue.state.rawValue
    let width = (text as NSString).boundingRect(with: CGSize(width: 0, height: 14), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil).width
    stateLabel.snp.updateConstraints { make in
      make.width.equalTo(width + 20)
    }
    stateLabel.text = issue.state.rawValue
    stateLabel.backgroundColor = issue.state.color
    
    let titleHeight = (titleLabel.text! as NSString).boundingRect(with: CGSize(width: FrameGuide.screenWidth - 24, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil).height
    titleLabel.snp.updateConstraints { make in
      make.height.equalTo(titleHeight)
    }
    comletionHandler?(titleHeight)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUp() {
    addSubview(avatarImageView)
    addSubview(titleLabel)
    addSubview(contentLabel)
    addSubview(stateLabel)

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(12)
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.height.equalTo(20)
    }
    avatarImageView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
      make.leading.equalTo(titleLabel)
      make.width.height.equalTo(20)
    }
    contentLabel.snp.makeConstraints { make in
      make.centerY.equalTo(avatarImageView)
      make.leading.equalTo(avatarImageView.snp.trailing).offset(5)
      make.trailing.equalTo(stateLabel.snp.leading).offset(-5)
    }
    stateLabel.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.width.equalTo(50)
      make.height.equalTo(24)
      make.centerY.equalTo(avatarImageView)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(touchTitleAction))
    titleLabel.addGestureRecognizer(tap)
    titleLabel.isUserInteractionEnabled = true
  }
  
  @objc func touchTitleAction() {
    touchedTitleClosure?()
  }
  
  @objc func updateStateAction() {
    if let issue = issue, case Issue.IssueState.open = issue.state {
      updateStateClosure?()
    }
  }
  
}

class RepoIssueDetailViewController: UIViewController {

  let userName: String
  let repoName: String
  let issueNum: Int
  
  var issue: IssueDetail?
  
  lazy var headerView: RepoIssueDetailHeaderView = {
    let headerView = RepoIssueDetailHeaderView()
    return headerView
  }()
  
  lazy var bodyView: MarkdownView = {
    let view = MarkdownView()
    return view
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  init(userName: String, repoName: String, issueNum: Int) {
    self.userName = userName
    self.repoName = repoName
    self.issueNum = issueNum
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
    updateIssue()
  }
  
  @objc func editAction() {
    let vc = TitleAndDescViewController(with: .editIssue(userName: userName, repoName: repoName, issueNum: issueNum))
    vc.completionHandler = { [weak self] in
      self?.updateIssue()
    }
    present(vc, animated: true)
  }
  
  func render(with issueDetail: IssueDetail) {
    self.issue = issueDetail
    
    if case Issue.IssueState.open = issueDetail.state {
      self.navigationItem.rightBarButtonItems = [
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction)),
        UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
      ]
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
    }
    headerView.render(with: issueDetail, comletionHandler: { [weak self] height in
      self?.headerView.snp.updateConstraints { make in
        make.height.equalTo(height + 64)
      }
      self?.bodyView.load(markdown: issueDetail.body, enableImage: true)
    })
  }
  
  private func setUp() {
    view.backgroundColor = .white
    self.navigationItem.title = repoName

    view.addSubview(scrollView)
    scrollView.addSubview(headerView)
    scrollView.addSubview(bodyView)

    scrollView.frame = CGRect(
      x: 0,
      y: FrameGuide.navigationBarAndStatusBarHeight,
      width: FrameGuide.screenWidth,
      height: FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight
    )
    headerView.snp.makeConstraints { make in
      make.height.equalTo(60)
      make.width.equalTo(FrameGuide.screenWidth)
      make.top.leading.equalTo(self.scrollView)
    }
    bodyView.snp.makeConstraints { make in
      make.leading.equalTo(headerView)
      make.trailing.equalTo(headerView)
      make.top.equalTo(headerView.snp.bottom).offset(10)
      make.height.equalTo(100)
    }
    scrollView.contentSize = CGSize(width: FrameGuide.screenWidth, height: FrameGuide.screenHeight)
    
    headerView.touchedTitleClosure = { [weak self] in
      guard let strongSelf = self else { return }
      if let issue = strongSelf.issue {
        strongSelf.navigationController?.pushToWebView(with: issue.htmlUrl)
      }
    }
    headerView.updateStateClosure = { [weak self] in
      guard let strongSelf = self else { return }
      let alertVC = UIAlertController(title: "", message: "Are you sure to close this issue?", preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "sure", style: .default, handler: { action in
        Task {
          if let _ = await RepoManager.updateIssue(
            with: strongSelf.userName,
            repoName: strongSelf.repoName,
            issueNum: strongSelf.issueNum,
            params: ["state": "closed"]
          ) {
            strongSelf.updateIssue()
          }
        }
      }))
      alertVC.addAction(UIAlertAction(title: "cancel", style: .cancel))
      strongSelf.present(alertVC, animated: true)
    }

    bodyView.onRendered = { [weak self] height in
      guard let strongSelf = self else { return }
      strongSelf.bodyView.snp.updateConstraints { make in
        make.height.equalTo(height)
      }
      let h = height + strongSelf.headerView.frame.height
      strongSelf.scrollView.contentSize = CGSize(
        width: FrameGuide.screenWidth, height: max(h, FrameGuide.screenHeight - FrameGuide.navigationBarAndStatusBarHeight))
    }
    bodyView.onTouchLink = { [weak self] request in
      guard let strongSelf = self, let urlString = request.url?.absoluteString else { return false }
      strongSelf.navigationController?.pushToWebView(with: urlString)
      return false
    }
    
  }
  
  private func updateIssue() {
    Task {
      if let issue = await RepoManager.getRepoIssueDetail(with: userName, repoName: repoName, issueNum: issueNum) {
        self.render(with: issue)
      }
    }
  }
  
  // Add issue comment
  @objc func addAction() {
    let vc = TitleAndDescViewController(with: .issueComment(userName: userName, repoName: repoName, issueNum: issueNum))
    present(vc, animated: true)
  }

}
