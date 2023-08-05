//
//  Date.swift
//  LostArkCombat
//
//  Created by Trading Taijoo on 2021/07/09.
//

import UIKit

class DateManager {
    static let shared = DateManager()
    
    fileprivate let dateFormat: String = "yyyy-MM-dd HH:mm:ss"
    
    var isAfterAM6: Bool {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
            
            guard let date = dateFormatter.string(for: Date()) else { return false }
            return date > "06:00"
        }
    }
    
    func convertDateFormat(_ date: String, originFormat: String, newFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = originFormat
        
        let date = dateFormatter.date(from: date) ?? Date()
        
        dateFormatter.dateFormat = newFormat
        
        return dateFormatter.string(from: date)
    }
    
    func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent

        return dateFormatter.string(for: Date()) ?? "Error"
    }
    
    func currentLocaleDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        return dateFormatter.string(for: Date()) ?? "Error"
    }
    
    func currentWeekday() -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
        calendar.locale = Locale(identifier: "ko_KR")
        
        let dateComponents = calendar.dateComponents([.weekday], from: Date())

        return dateComponents.weekday ?? 0
    }
    
    func currentDistance(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
                        
        let date = dateFormatter.date(from: date) ?? Date()
        let today = dateFormatter.date(from: currentDate()) ?? Date()

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
        calendar.locale = Locale(identifier: "ko_KR")

        let distance = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: today)
        guard let year = distance.year,
              let month = distance.month,
              let day = distance.day,
              let hour = distance.hour,
              let minute = distance.minute,
              let second = distance.second else { return "" }

        if year > 0 {
            return "\(year)년 전"
        } else if month > 0 {
            return "\(month)개월 전"
        } else if day > 0 {
            return "\(day)일 전"
        } else if hour > 0 {
            return "\(hour)시간 전"
        } else if minute > 0 {
            return "\(minute)분 전"
        } else if second >= 0 {
            return "\(second)초 전"
        }
        
        return ""
    }
    
    // LostArk
    func calculateDate(_ date: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
                        
        var date = dateFormatter.date(from: date) ?? Date()
        var today = dateFormatter.date(from: currentDate()) ?? Date()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
        calendar.locale = Locale(identifier: "ko_KR")
        
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .weekday, .weekOfYear, .yearForWeekOfYear], from: date)
        let hour = dateComponents.hour!
        
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .weekday, .weekOfYear, .yearForWeekOfYear], from: today)
        let now = dateComponents.hour!
        
        dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        date = calendar.date(from: dateComponents) ?? date

        dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        today = calendar.date(from: dateComponents) ?? Date()

        var distance = calendar.dateComponents([.day], from: date, to: today).day ?? -1
        if hour < 6 && now >= 6 { distance += 1 }
        if distance >= 1 && hour >= 6 && now < 6 { distance -= 1 }
        
        return distance
    }
    
    func nextLoaWeekday(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent

        let date = dateFormatter.date(from: date) ?? Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .weekday, .weekOfYear, .yearForWeekOfYear], from: date)
        
        let weekOfYear = dateComponents.weekday! >= 4 ? (dateComponents.weekday! == 4 && dateComponents.hour! < 6 ? 0 : 1 ) : 0
        let nextLoaWeekday = calendar.date(from: DateComponents(year: dateComponents.year,
                                                                hour: 6,
                                                                weekday: 4,
                                                                weekOfYear: dateComponents.weekOfYear! + weekOfYear,
                                                                yearForWeekOfYear: dateComponents.yearForWeekOfYear))!
                
        return dateFormatter.string(from: nextLoaWeekday)
    }
}
