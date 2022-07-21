//
//  User.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/04.
//

import UIKit
import CloudKit

class User {
    static let shared = User()
    
    private init() { }
    
    var isConnected: Bool {
        set(value) {
            UserDefaults.standard.set(value, forKey: "isConnected")
        }
        
        get {
            return UserDefaults.standard.bool(forKey: "isConnected")
        }
    }
    
    var identifier: String {
        set(value) {
            Keychain.saveKeychain(value, forKey: "identifier")
        }
        
        get {
            return Keychain.currentKeychain(forKey: "identifier")
        }
    }
    
    var stove: String {
        set(value) {
            Keychain.saveKeychain(value, forKey: "stove")
        }
        
        get {
            return Keychain.currentKeychain(forKey: "stove")
        }
    }
    
    var name: String {
        set(value) {
            Keychain.saveKeychain(value, forKey: "name")
        }
        
        get {
            return Keychain.currentKeychain(forKey: "name")
        }
    }
    
    var sequence: String {
        set(value) {
            Keychain.saveKeychain(value, forKey: "sequence")
        }
        
        get {
            return Keychain.currentKeychain(forKey: "sequence")
        }
    }    
}
