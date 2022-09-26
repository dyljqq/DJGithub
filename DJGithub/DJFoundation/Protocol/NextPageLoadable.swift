//
//  NextPageLoadable.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import UIKit

struct NextPageState {
  
  private(set) var start: Int
  private(set) var hasNext: Bool
  private(set) var isLoading: Bool
  
  init() {
    start = 0
    hasNext = true
    isLoading = false
  }
  
  mutating func reset() {
    start = 0
    hasNext = true
    isLoading = false
  }
  
  mutating func update(start: Int, hasNext: Bool, isLoading: Bool) {
    self.start = start
    self.hasNext = hasNext
    self.isLoading = isLoading
  }
  
}

protocol NextPageLoadable: AnyObject {
  
  associatedtype DataType
  
  var firstPageIndex: Int { get }
  var dataSource: [DataType] { get set }
  var nextPageState: NextPageState { get set }
  
  func performLoad(
    successHandler: @escaping (_ rows: [DataType], _ hasNext: Bool) -> (), failureHandler: @escaping (String) -> ())
  
}

extension NextPageLoadable {
  
  var firstPageIndex: Int {
    return 0
  }
  
  func loadNext(start: Int, completionHandler: (() -> ())? = nil) {
    guard nextPageState.hasNext, !nextPageState.isLoading else { return }
    
    nextPageState.update(start: start, hasNext: nextPageState.hasNext, isLoading: true)
    
    performLoad(successHandler: { [weak self] items, hasNext in
      guard let strongSelf = self else { return }
      
      if start == strongSelf.firstPageIndex {
        strongSelf.dataSource.removeAll()
      }
      
      strongSelf.dataSource.append(contentsOf: items)
      strongSelf.nextPageState.update(start: strongSelf.nextPageState.start + 1, hasNext: hasNext, isLoading: false)
      
      completionHandler?()
      
    }, failureHandler: { msg in
      completionHandler?()
    })
  }
  
}
