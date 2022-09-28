//
//  utils.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

func UIColorFromRGB(_ rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
  return UIColor(
    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
    alpha: alpha
  )
}

func isEmpty(by str: String?) -> Bool {
  return str == nil || str!.isEmpty
}

func loadBundleJSONFile<T: Decodable>(_ filename: String) -> T {
  do {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: loadBundleData(filename))
  } catch {
    fatalError("Couldn't find \(filename) in main bundle")
  }
}

func loadBundleData(_ filename: String) -> Data {
    let data: Data
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    do {
        data = try Data(contentsOf: file)
        return data
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
}
