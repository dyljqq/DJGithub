//
//  RepoFeedbackViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/6.
//

import UIKit

class RepoFeedbackViewController: UIViewController {

  enum RepoFeedbackType {
    case issue(userName: String, repoName: String)
    case issueComment(userName: String, repoName: String, issueNum: Int)
  }
  
  let type: RepoFeedbackType
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "New Issue"
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
    textView.placeholder = "issue content"
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
  
  init(with type: RepoFeedbackType) {
    self.type = type
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
    view.backgroundColor = .backgroundColor
    self.navigationItem.title = "New Issue"
    
    let headerView = UIView()
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
      make.top.equalTo(titleTextField.snp.bottom).offset(20)
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
      
      guard !title.isEmpty else {
        commitView.isLoading = false
        return
      }
      
      let params: [String: String] = [
        "title": title,
        "body": content
      ]
      switch type {
      case .issue(let userName, let repoName):
        if let statusCode = await RepoManager.createNewIssue(with: userName, repoName: repoName, params: params) {
          commitView.isLoading = false
        } else {
          commitView.isLoading = false
        }
      case .issueComment(let userName, let repoName, let issueNum):
        break
      }
    }
  }
  
  @objc func cancelAction() {
    self.dismiss(animated: true)
  }

}

extension RepoFeedbackViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    print("text: \(text), range: \(range)")
    return true
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
  }
}
