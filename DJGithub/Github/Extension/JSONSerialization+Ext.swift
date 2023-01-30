//
//  JSONSerialization+Ext.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import Foundation

extension JSONSerialization {
    
    @discardableResult
    static func loadJSON<T: Codable>(withFilename filename: String) throws -> T? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try Data(contentsOf: fileURL)
            return try DJDecoder(data: data).decode()
        }
        return nil
    }
    
    @discardableResult
    static func save(jsonObject: Any, toFilename filename: String) throws -> Bool{
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            try data.write(to: fileURL, options: [.atomicWrite])
            return true
        }
        
        return false
    }
}
