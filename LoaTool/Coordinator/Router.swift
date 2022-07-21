//
//  Router.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

protocol Router: AnyObject {
    func present(_ viewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool)
}

extension UIWindow: Router {
    func present(_ viewController: UIViewController, animated: Bool) {
        rootViewController = viewController
        makeKeyAndVisible()
    }
    
    func dismiss(animated: Bool) {
        rootViewController = nil
    }
}

extension UIViewController: Router {
    func present(_ viewController: UIViewController, animated: Bool) {
        self.present(viewController, animated: animated, completion: nil)
    }
    
    func dismiss(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
}
