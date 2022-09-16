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
      if let d = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
        return .success(d)
      } else {
        return .failure(.parseError("json parse error"))
      }
    } catch {
      print("APIClient get data error: \(error)")
    }
    return .failure(.requestError)
  }
}
