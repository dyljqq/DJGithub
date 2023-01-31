//
//  DJFileManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct DJFileManager {

    static let `default` = DJFileManager()

    @discardableResult
    func createDir(with dirName: String) -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = documentURL.appendingPathComponent(dirName, isDirectory: true)

        guard !dirExists(at: url) else { return url }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        } catch {
            print("Error to create dir.")
            return nil
        }
    }

    func save(with data: Data, path: String) {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = documentURL.appendingPathComponent(path)
        save(with: data, url: url)
    }

    func save(with data: Data, url: URL) {
        do {
            try data.write(to: url)
        } catch {
            print("Error to save data: \n url: \(url) \n \(error)")
        }
    }

    func dirExists(at path: URL) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false)
        let isExist = FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory)
        return isExist
    }

    func load<T: Codable>(with filename: String) -> T? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let filePath = url.appendingPathComponent(filename, isDirectory: false)
        guard let data = FileManager.default.contents(atPath: filePath.path) else { return nil }
        return try? DJDecoder(data: data).decode()
    }
}
