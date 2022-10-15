//
//  RepoFeedbackViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/6.
//

import UIKit

class TitleAndDescViewController: UIViewController {

  enum VCType {
    case issue(userName: String, repoName: String)
    case editIssue(userName: String, repoName: String, issueNum: Int)
    case issueComment(userName: String, repoName: String, issueNum: Int)
    case rssFeed
  }
  
  let type: VCType
  var completionHandler: (() -> ())? = nil
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .textColor
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.setTitle("cancel", for: .normal)
    button.setTitleColor(.textColor, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    return button
  }()
  
  lazy var titleTextField: UITextField = {
    let textField = UITextField()
    textField.textColor = .textColor
    textField.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    textField.placeholder = "title"
    textField.layer.cornerRadius = 5
    textField.layer.masksToBounds = true
    textField.backgroundColor = .white
    
    let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
    textField.leftView = leftView
    textField.leftViewMode = .always
    
    return textField
  }()
  
  lazy var descTextView: UITextView = {
    let textView = UITextView()
    textView.textColor = .textColor
    textView.font = UIFont.systemFont(ofSize: 14)
    textView.delegate = self
    textView.layer.cornerRadius = 5
    textView.layer.masksToBounds = true
    textView.textContainer.lineFragmentPadding = 15
    textView.placeholder = "Issue content"
    return textView
  }()
  
  lazy var commitView: CommitView = {
    let view = CommitView(with: "commit")
    view.backgroundColor = .lightBlue
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    view.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(commitAction))
    view.addGestureRecognizer(tap)
    return view
  }()
  
  let headerView = UIView()
  
  init(with type: VCType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
    
    switch type {
    case .editIssue(let userName, let repoName, let issueNum):
      titleLabel.text = "Edit Issue"
      fetchIssueDetail(with: userName, repoName: repoName, issueNum: issueNum)
    case .issue:
      titleLabel.text = "Create Issue"
    case .issueComment:
      titleLabel.text = "Create Issue Comment"
      self.titleTextField.isHidden = true
      self.descTextView.snp.updateConstraints { make in
        make.top.equalTo(headerView.snp.bottom).offset(20)
      }
      self.descTextView.placeholder = "Issue comment content"
    case .rssFeed:
      titleLabel.text = "Add Rss"
      self.titleTextField.placeholder = "Add feed link"
      self.descTextView.placeholder = "Rss Feed Description."
    }
  }
  
  private func fetchIssueDetail(with userName: String, repoName: String, issueNum: Int) {
    Task {
      if let issue = await RepoManager.getRepoIssueDetail(with: userName, repoName: repoName, issueNum: issueNum) {
        self.titleTextField.text = issue.title
        self.descTextView.placeholder = ""
        self.descTextView.text = issue.body
      }
    }
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
    
    headerView.backgroundColor = .white
    view.addSubview(headerView)
    
    headerView.addSubview(self.titleLabel)
    headerView.addSubview(self.cancelButton)
    
    view.addSubview(titleTextField)
    view.addSubview(descTextView)
    view.addSubview(commitView)
    
    headerView.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.top.leading.trailing.equalToSuperview()
    }
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    cancelButton.snp.makeConstraints { make in
      make.trailing.equalTo(-12)
      make.centerY.equalToSuperview()
    }
    titleTextField.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(40)
      make.top.equalTo(headerView.snp.bottom).offset(20)
    }
    descTextView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom).offset(80)
      make.leading.equalTo(titleTextField)
      make.centerX.equalToSuperview()
      make.height.equalTo(200)
    }
    commitView.snp.makeConstraints { make in
      make.top.equalTo(descTextView.snp.bottom).offset(20)
      make.leading.equalTo(40)
      make.centerX.equalToSuperview()
      make.height.equalTo(44)
    }
  }
  
  @objc func commitAction() {
    commitView.isLoading = true
    
    Task {
      let title = titleTextField.text ?? ""
      let content = descTextView.text ?? ""
      
      let params: [String: String] = [
        "title": title,
        "body": content
      ]
      switch type {
      case .issue(let userName, let repoName):
        guard !title.isEmpty else { break }
        if let statusCode = await RepoManager.createNewIssue(with: userName, repoName: repoName, params: params),
           statusCode.isStatus201 {
          self.dismiss(animated: true, completion: { [weak self] in
            self?.completionHandler?()
          })
        } else {
          HUD.show(with: "Fail to create issue.")
        }
        commitView.isLoading = false
      case .issueComment(let userName, let repoName, let issueNum):
        guard !content.isEmpty else { break }
        if let status = await RepoManager.createIssueComment(with: userName, repoName: repoName, issueNum: issueNum, params: ["body": content]),
           status.isStatus201 {
          self.dismiss(animated: true, completion: { [weak self] in
            self?.completionHandler?()
          })
        } else {
          HUD.show(with: "Fail to create issue comment.")
        }
      case .editIssue(let userName, let repoName, let issueNum):
        guard !title.isEmpty else { break }
        if let _ = await RepoManager.updateIssue(with: userName, repoName: repoName, issueNum: issueNum, params: params) {
          self.dismiss(animated: true, completion: { [weak self] in
            self?.completionHandler?()
          })
        } else {
          HUD.show(with: "Fail to update issue.")
        }
      case .rssFeed:
        guard !title.isEmpty else { return }
        let isAdded = await ConfigManager.shared.rssFeedManager.addAtom(with: title, desc: content)
        if isAdded {
          self.dismiss(animated: true, completion: { [weak self] in
            self?.completionHandler?()
          })
        } else {
          HUD.show(with: "Fail to add atom.")
        }
      }
      commitView.isLoading = false
    }
  }
  
  @objc func cancelAction() {
    self.dismiss(animated: true)
  }

}

extension TitleAndDescViewController: UITextViewDelegate {
}
