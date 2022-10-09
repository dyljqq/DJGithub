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
  
  func data(with urlString: String) async throws -> Data? {
    do {
      guard let url = URL(string: urlString) else { return nil }
      let (data, _) = try await URLSession.shared.data(from: url)
      return data
    } catch {
      print("url session debug info:")
      print("fetch error: \(urlString), error: \(error)")
      print("------------------------")
    }
    return nil
  }
  
  func data(with router: Router) async throws -> Data {
    guard let request = router.asURLRequest() else { throw DJError.requestError }
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      return data
    } catch {
      router.printDebugInfo(with: error)
      throw DJError.dataError
    }
  }
  
  func model<T: DJCodable>(with router: Router, decoder: any Parsable = DJJSONParser<T>()) async throws -> T? {
    guard let request = router.asURLRequest() else { throw DJError.requestError }
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpReponse = response as? HTTPURLResponse, httpReponse.statusCode != 200 {
        let dict = ["statusCode": httpReponse.statusCode]
        return try DJDecoder(dict: dict).decode()
      }
      return try await decoder.parse(with: data) as? T
    } catch {
      router.printDebugInfo(with: error)
      throw DJError.dataError
    }
  }
  
  func data<T: DJCodable>(with urlString: String, decoder: any Parsable = DJJSONParser<T>()) async throws -> T? {
    do {
      guard let url = URL(string: urlString) else { return nil }
      let (data, _) = try await URLSession.shared.data(from: url)
      return try? decoder.parse(with: data) as? T
    } catch {
      print("url session debug info:")
      print("fetch error: \(urlString), error: \(error)")
      print("------------------------")
    }
    return nil
  }
  
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
  
  func get<T: DJCodable>(with urlString: String) async -> T? {
    do {
      guard let url = URL(string: urlString) else {
        return nil
      }
      let (data, _) = try await URLSession.shared.data(from: url)
      return try? DJDecoder(data: data).decode()
    } catch {
      print("fetch error: \(urlString), error: \(error)")
    }
    return nil
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
  
  func fetch<T: DJCodable>(by router: Router) -> AnyPublisher<T, DJError> {
    return self._fetch(by: router)
      .tryMap { d in
        return try JSONSerialization.data(withJSONObject: d, options: .prettyPrinted)
      }
      .decode(type: T.self, decoder: decoder)
      .mapError { DJError.map($0) }
      .eraseToAnyPublisher()
  }
}
