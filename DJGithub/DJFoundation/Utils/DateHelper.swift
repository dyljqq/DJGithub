//
//  DateHelper.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

func getInternetDateFormatter() -> DateFormatter {
    let posix = Locale(identifier: "en_US_POSIX")
    let formmater = DateFormatter()
    formmater.locale = posix
    formmater.timeZone = TimeZone(secondsFromGMT: 0)
    return formmater
}

func getFeedDateFormatter() -> DateFormatter {
    let formmatter = DateFormatter()
    formmatter.dateFormat = "MM-dd HH:mm"
    return formmatter
}

struct DateHelper {
    
    static let standard = DateHelper()
    
    static let feedDateFormatter = getFeedDateFormatter()
    static let internetDateFormatter = getInternetDateFormatter()
    
    let formatters = [
        "EEE, d MMM yyyy HH:mm:ss zzz",
        "EEE, d MMM yyyy HH:mm zzz",
        "EEE, d MMM yyyy HH:mm:ss",
        "EEE, d MMM yyyy HH:mm"
    ]
    
    func dateFromRFC822String(_ dateString: String) -> Date? {
        let formatter = DateHelper.internetDateFormatter
        let RFC822String = dateString.uppercased()
        if RFC822String.contains(",") {
            for f in formatters {
                formatter.dateFormat = f
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.date(from: dateString)
        }
        
        return nil
    }
    
    func dateToString(_ date: Date) -> String {
        return DateHelper.feedDateFormatter.string(from: date)
    }
    
}
