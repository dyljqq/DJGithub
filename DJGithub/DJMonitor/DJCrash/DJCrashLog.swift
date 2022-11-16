//
//  DJCrashLog.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/1.
//

import Foundation

struct DJCrashLogManager {

  static let crashLogName: String = "crashLog.log"
  static let crashLogDir: String = "CrashLog"

  static var crashLogs: [DJCrashLog] {
    guard let dir = crashLogPath() else { return [] }
    do {
      let logPath = dir.appendingPathComponent(crashLogName)
      if let data = FileManager.default.contents(atPath: logPath.path), !data.isEmpty {
        let rs: [DJCrashLog]? = try DJDecoder(data: data).decode()
        return rs ?? []
      }
    } catch {
      print("error: \(error)")
    }
    return []
  }

  static func collect(with exception: NSException, stackInfo: String, viewControllerInfo: String) {
    let enviroment: String
#if DEBUG
    enviroment = "DEBUG"
#else
    enviroment = "RELEASE"
#endif

    let dict: [String: Any] = [
      "logDate": String(format: "%.2f", Date.now.timeIntervalSince1970),
      "type": exception.name,
      "bundleVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "",
      "enviroment": enviroment,
      "track": viewControllerInfo,
      "exceptionLog": [
        "name": exception.name,
        "reason": exception.reason ?? "",
        "stackInfo": stackInfo
      ]
    ]

    guard let logDir = crashLogPath() else { return }
    do {
      let logPath = logDir.appendingPathComponent(crashLogName, isDirectory: true)
      var rs: [[String: Any]] = []
      if let data = FileManager.default.contents(atPath: logPath.path), !data.isEmpty,
         let logs = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
        rs = logs
      }
      rs.append(dict)
      let data = try JSONSerialization.data(withJSONObject: rs)
      try data.write(to: logPath)
    } catch {
      print("DJCrashLogManager collect error: \(error)")
    }
  }

  static func crashLogPath() -> URL? {
    guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let url = documentURL.appendingPathComponent(crashLogDir, isDirectory: true)
    var isDirectory: ObjCBool = ObjCBool(false)
    let isExist = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    if !isExist {
      do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
      } catch {
        print("crashLogPath error: \(error)")
        return nil
      }
    }
    return url
  }

  static func clearAll() {
    guard let dir = crashLogPath() else { return }
    let logPath = dir.appendingPathComponent(crashLogName)
    try? FileManager.default.removeItem(atPath: logPath.path)
  }
}

struct DJCrashLog: DJCodable {
  var logDate: String
  var type: String
  var bundleVersion: String
  var exceptionLog: DJExceptionLog
  var enviroment: String
  var track: String
}

struct DJExceptionLog: DJCodable {
  var name: String
  var reason: String
  var stackInfo: String
}
