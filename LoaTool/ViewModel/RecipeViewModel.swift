//
//  RecipeViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/13.
//

import UIKit

class RecipeViewModel {
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
    
    func filter(contains text: String) {
        guard let data = data,
              text != "" else {
            
            filter.value = self.data
            return
        }
        
        filter.value = data.filter { $0.name.contains(text) }
    }
}
