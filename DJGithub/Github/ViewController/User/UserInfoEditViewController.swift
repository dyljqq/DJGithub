//
//  UserInfoEditViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/8.
//

import UIKit

class UserInfoEditViewController: UIViewController {

  let type: UserInfoType
  let user: User?

  lazy var textField: UITextField = {
    let textField = UITextField()
    textField.backgroundColor = .white
    textField.text = type.getContent(by: user)
    textField.font = UIFont.systemFont(ofSize: 14)
    textField.textColor = .textColor
    textField.clearButtonMode = .always
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    textField.leftViewMode = UITextField.ViewMode.always
    return textField
  }()

  lazy var textView: UITextView = {
    let textView = UITextView()
    textView.text = type.getContent(by: user)
    textView.textColor = .textColor
    textView.font = UIFont.systemFont(ofSize: 14)
    textView.backgroundColor = .white
    return textView
  }()

  lazy var commitView: CommitView = {
    let commitView = CommitView(with: "commit")
    commitView.backgroundColor = .lightBlue
    return commitView
  }()

  init(with type: UserInfoType, user: User?) {
    self.type = type
    self.user = user
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
    self.navigationItem.title = type.name

    view.addSubview(textField)
    view.addSubview(textView)
    view.addSubview(commitView)

    if case UserInfoType.bio = self.type {
      textField.isHidden = true
      textView.isHidden = false
      textView.snp.makeConstraints { make in
        make.height.equalTo(160)
        make.top.equalTo(20 + FrameGuide.navigationBarAndStatusBarHeight)
        make.leading.trailing.equalToSuperview()
      }
      commitView.snp.makeConstraints { make in
        make.top.equalTo(textView.snp.bottom).offset(20)
        make.leading.equalTo(40)
        make.centerX.equalToSuperview()
        make.height.equalTo(34)
      }
    } else {
      textField.isHidden = false
      textView.isHidden = true
      textField.snp.makeConstraints { make in
        make.height.equalTo(30)
        make.top.equalTo(20 + FrameGuide.navigationBarAndStatusBarHeight)
        make.leading.trailing.equalToSuperview()
      }
      commitView.snp.makeConstraints { make in
        make.top.equalTo(textField.snp.bottom).offset(20)
        make.leading.equalTo(40)
        make.centerX.equalToSuperview()
        make.height.equalTo(34)
      }
    }

    commitView.commitClosure = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.commitView.isLoading = true
      let text: String?
      if case UserInfoType.bio = strongSelf.type {
        text = strongSelf.textView.text
      } else {
        text = strongSelf.textField.text
      }
      let key = strongSelf.type.rawValue
      Task {
        if let _ = await UserManager.editUserInfo(with: [key: text ?? ""]) {
          _ = strongSelf.navigationController?.popViewController(animated: true)
        } else {
          HUD.show(with: "Failed to update \(strongSelf.type.name)")
        }
        strongSelf.commitView.isLoading = false
      }
    }
  }

}
