//
//  FeedsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import UIKit

class FeedsViewController: UIViewController, NextPageLoadable {
  
  typealias DataType = FeedInfo
  
  var dataSource: [FeedInfo] = []
  var nextPageState: NextPageState = NextPageState()
  

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUp()
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
  }
  
  func performLoad(successHandler: @escaping ([FeedInfo], Bool) -> (), failureHandler: @escaping (String) -> ()) {
    
  }

}
