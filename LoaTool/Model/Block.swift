//
//  Block.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/28.
//

import UIKit

class Block {
    var identifier: String
    var name: String
    var date: String
    
    /**
     구성 요소
     
     - parameters:
        - identifier: 차단 고유값
        - name: 이름
        - text: 내용
     */
    
    init(identifier: String, name: String, date: String) {
        self.identifier = identifier
        self.name = name
        self.date = date
    }
}
