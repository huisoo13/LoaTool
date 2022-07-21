//
//  Storyboarded.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/12/30.
//

import UIKit

protocol Storyboarded {
    static func instantiate(_ name: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(_ name: String = "Main") -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
