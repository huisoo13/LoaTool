//
//  CalculatorViewModel.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/08.
//

import UIKit

class CalculatorViewModel {
    var data: [Recipe]?
    var filter = Bindable<[Recipe]>()
    
    var timer: Timer?

    func configure(_ target: UIViewController) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            API.post.selectRecipe(target) { data in
                self.data = data
                self.filter.value = data
            }
        })
    }
    
    func importPreviousData() {
        
    }

}
