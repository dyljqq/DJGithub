//
//  ViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    Task {
      let user = await UserViewModel.getUser(with: "dyljqq")
    }
  }
}

