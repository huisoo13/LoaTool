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
        
        /* !!!: ISSUE - AWS 중지
        API.get.selectPost(target, page: number, filter: options) { data in
            self.numberOfItem = data.count
            
            if number == 0 {
                self.result.value = data
            } else {
                self.result.value?.append(contentsOf: data)
            }
        }
         */
        
        let notice = Community(identifier: "00000",
                               owner: "NOTICE",
                               name: "후이수",
                               job: "바드",
                               level: 1635,
                               server: "@아만",
                               text: "안녕하세요. 로아툴 개발자입니다.\n\n컨텐츠 아이콘이 추가되었습니다./n카제로스 레이드 아이콘을 추가하고 싶었으나 해당 아이콘은 구하지 못해서 추후에 구하면 추가하겠습니다.\n\n이번에 추가된 아이콘은 군단장 레이드 스페셜 아이콘과 초록색 관문 아이콘입니다.",
                               imageURL: [],
                               gateway: "",
                               numberOfLiked: 0,
                               numberOfComment: 0,
                               isLiked: false,
                               isMarked: false,
                               date: "2024-02-28 10:00:00")
        
        self.result.value = [notice]
    }
}
