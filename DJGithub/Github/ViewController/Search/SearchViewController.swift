//
//  SearchViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import UIKit

class SearchViewController: UIViewController {
  
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.delegate = self
    return searchBar
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  private func setUp() {
    view.backgroundColor = .backgroundColor
    
    let vc = UserFollowingViewController(with: .search("dyljqq"))
    addChild(vc)
    view.addSubview(vc.view)
    
    vc.view.frame = view.bounds
    
    self.navigationItem.titleView = searchBar
  }

}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
  }
}
