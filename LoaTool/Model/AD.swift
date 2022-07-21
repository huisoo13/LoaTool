//
//  AD.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/29.
//

import UIKit
import RealmSwift

class AD: Object {
    @objc dynamic var URL: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var title: String = ""
    
    override class func primaryKey() -> String? {
        return "URL"
    }

    override init() {
        super.init()
    }
    
    init(URL: String, imageURL: String, title: String) {
        self.URL = URL
        self.imageURL = imageURL
        self.title = title
    }
}
