//
//  AppStyle.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/30.
//

import UIKit

enum AppStyle {
  case gray

  var color: UIColor {
    switch self {
    case .gray: return .lightGray
    }
  }
}
