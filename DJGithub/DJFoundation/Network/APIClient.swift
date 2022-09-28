//
//  APIClient.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation
import Combine

open class APIClient {
  static let shared = APIClient()
  
  lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
  
  func get(by router: Router) async -> Result<[String: Any], DJError> {
    guard let request = router.asURLRequest() else {
      return .failure(.unknown)
    }
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        return .success(["statusCode": httpResponse.statusCode])
      }
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
  
  private func _fetch(by router: Router) -> AnyPublisher<[String: Any], DJError> {
    guard let request = router.asURLRequest() else {
      return Fail(error: DJError.requestError).eraseToAnyPublisher()
    }
    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { resposne -> Data in
        guard let httpResponse = resposne.response as? HTTPURLResponse else {
          throw DJError.requestError
        }
        
        guard httpResponse.statusCode == 200 else {
          throw DJError.statusCode(httpResponse.statusCode)
        }
        
        return resposne.data
      }
      .tryMap { data in
        let r = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        let d: [String: Any]
        if let r = r as? [Any] {
          d = ["items": r]
        } else if let r = r as? [String: Any] {
          d = r
        } else {
          d = [:]
        }
        return d
      }
      .mapError { DJError.map($0) }
      .eraseToAnyPublisher()
  }
  
  func fetch<T: Decodable>(by router: Router) -> AnyPublisher<T, DJError> {
    return self._fetch(by: router)
      .tryMap { d in
        return try JSONSerialization.data(withJSONObject: d, options: .prettyPrinted)
      }
      .decode(type: T.self, decoder: decoder)
      .mapError { DJError.map($0) }
      .eraseToAnyPublisher()
  }
}
