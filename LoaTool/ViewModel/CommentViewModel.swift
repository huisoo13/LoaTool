//
//  CommentViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/20.
//

import UIKit

class CommentViewModel {
    var result = Bindable<[Comment]>()
    var numberOfItem: Int = 0
    
    func configure(_ target: UIViewController, type: Int = 0, identifier: String, page number: Int = 0) {
        API.get.selectComment(target, type: type, identifier: identifier, page: number, completionHandler: { data in
            self.numberOfItem = data.count

            if number == 0 {
                self.result.value = data
            } else {
                self.result.value?.append(contentsOf: data)
            }
        })
    }
}
