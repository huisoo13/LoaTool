//
//  NotificationViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/28.
//

import UIKit

class NotificationViewModel {
    var result = Bindable<[Notification]>()
    
    func configure(_ target: UIViewController) {
        API.get.selectNotification(target) { data in
            UIApplication.shared.applicationIconBadgeNumber = 0
            UserDefaults.standard.set(false, forKey: "showBadge")
            
            self.result.value = data
        }
    }
}
