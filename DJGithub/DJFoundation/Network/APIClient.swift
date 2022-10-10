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
      return try? await decoder.parse(with: data) as? T
    } catch {
      print("url session debug info:")
      print("fetch error: \(urlString), error: \(error)")
      print("------------------------")
    }
    return nil
  }
}
