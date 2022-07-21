//
//  Regex.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/06/01.
//

import Foundation

extension String {
    var isEmailAddress: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let text = NSPredicate(format:"SELF MATCHES %@", regex)
        return text.evaluate(with: self)
    }
    
    var isPassword: Bool {
        let regex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^*?_~+=-]).{8,16}$"
        let text = NSPredicate(format:"SELF MATCHES %@", regex)
        return text.evaluate(with: self)
    }
    
    var isPhoneNumber: Bool {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let text = NSPredicate(format:"SELF MATCHES %@", regex)
        return text.evaluate(with: self)
    }
    
    var isURL: Bool {
        let regex = "[(http(s)?):\\/\\/(www\\.)?a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
        let text = NSPredicate(format:"SELF MATCHES %@", regex)
        return text.evaluate(with: self)
    }
}
