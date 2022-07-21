//
//  Locailzed.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//
/* Usage
 → "Text".localized
 → "Text".localized()
 → "Text".localized(comment: "Comment")
 → "%@ Text".localized(with: "1")
 → "%@ Text".localized(with: ["1", "2"])
 */

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: comment)
    }
    
    func localized(with argument: CVarArg, comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }

    func localized(with arguments: [CVarArg], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), arguments: arguments)
    }
}
