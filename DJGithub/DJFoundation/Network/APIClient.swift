//
//  APIClient.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

open class APIClient {
  static let shared = APIClient()
  
  func get(by router: Router) async -> Result<[String: Any], DJError> {
    guard let request = router.asURLRequest() else {
      return .failure(.unknown)
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let r = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
      let d: [String: Any]
      if let r = r as? [Any] {
        d = ["items": r]
      } else if let r = r as? [String: Any] {
        d = r
      } else {
        d = [:]
      }
      return .success(d)
    } catch {
      print("APIClient get data error: \(error)")
    }
    return .failure(.requestError)
  }
}
