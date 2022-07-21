//
//  BlockViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/28.
//

import UIKit

class BlockViewModel {
    var result = Bindable<[Block]>()
    
    func configure(_ target: UIViewController) {
        API.get.selectBlock(target) { data in
            self.result.value = data
        }
    }
    
    func update(_ target: UIViewController, identifier: String, completionHandler: ((_ result: Bool)->())? = nil) {
        API.post.updateBlock(identifier, type: 1) { result in
            completionHandler?(result)
        }
    }
}
