//
//  Alert.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//

import UIKit

class Alert {
    enum Option {
        case onlySuccessAction
        case successAndCancelAction
    }
    
    static func message(_ target: UIViewController, title: String?, message: String?, option: Alert.Option? = nil,  handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if option == .successAndCancelAction {
            alert.addAction(UIAlertAction(title: "취소".localized, style: .destructive, handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { action in
            guard let handler = handler else { return }
            handler(action)
        }))
        
        target.present(alert, animated: true, completion: nil)
    }
    
    static func networkError(_ target: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: "네트워크 연결 상태를 확인해주세요.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { action in
            guard let handler = handler else { return }
            handler(action)
        }))
        
        target.present(alert, animated: true, completion: nil)
    }
    
    static func unknownError(_ target: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: "죄송합니다. 문제가 발생했습니다. 나중에 다시 시도해주세요.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { action in
            guard let handler = handler else { return }
            handler(action)
        }))
        target.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    // 액션시트 애니메이션 관련 불필요한 에러 로그 제거
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

