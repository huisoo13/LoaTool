//
//  CommunityViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/29.
//

import UIKit

class CommunityViewModel {
    var result = Bindable<[Community]>()
    var options = Bindable<FilterOption>()
    var numberOfItem: Int = 0
    
    func configure(_ target: UIViewController, page number: Int = 0, options: FilterOption? = FilterOption()) {
        let options = options == nil ? FilterOption() : options!
        
        API.get.selectPost(target, page: number, filter: options) { data in
            self.numberOfItem = data.count
            
            if number == 0 {
                self.result.value = data
            } else {
                self.result.value?.append(contentsOf: data)
            }
        }
    }
}
