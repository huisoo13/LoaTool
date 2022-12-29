//
//  OSTViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/08.
//

import UIKit

class OSTViewModel {
    var data = Bindable<[OST]>()
    var selectedItem = Bindable<OST>()
    var isDragging = Bindable<Bool>()
    
    var timer: Timer?

    func configure() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            self.data.value = OST.data()
        })
    }
}
