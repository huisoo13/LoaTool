//
//  Version.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/08.
//

import UIKit

class Version {
    static var isUpdateAvailable: Bool {
        get {
            return Version.now() < Version.new()
        }
    }
    
    // 기기에 설치된 앱 버전
    static func now() -> String {
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
            return "0.0.0"
        }
    }
    
    // 앱 스토어 최신 버전
    static func new() -> String {
        let HTTPS = "http://itunes.apple.com/kr/lookup?id=1580507503"

        guard let URL_HTTPS = URL(string: HTTPS),
              let DATA_HTTPS = try? Data(contentsOf: URL_HTTPS),
              let JSON_HTTPS = try? JSONSerialization.jsonObject(with: DATA_HTTPS, options: .allowFragments) as? [String: Any],
              let RESULT_HTTPS = JSON_HTTPS["results"] as? [[String: Any]],
              let VERSION_HTTPS = RESULT_HTTPS[safe: 0]?["version"] as? String else {
                  return UserDefaults.standard.string(forKey: "APP_STORE_VERSION") ?? now()
              }

        let APP_STORE_VERSION = VERSION_HTTPS < now() ? now() : VERSION_HTTPS
        UserDefaults.standard.set(APP_STORE_VERSION, forKey: "APP_STORE_VERSION")
        
        return APP_STORE_VERSION
    }
}
