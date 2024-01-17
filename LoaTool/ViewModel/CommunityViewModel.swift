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
                               level: 1630,
                               server: "@아만",
                               text: "안녕하세요. 로아툴 개발자입니다.\n\n브레이커 아이콘 추가와 컨텐츠 프리셋 내용 수정 및 기타 버그 수정 업데이트를 진행하였습니다.",
                               imageURL: [],
                               gateway: "",
                               numberOfLiked: 0,
                               numberOfComment: 0,
                               isLiked: false,
                               isMarked: false,
                               date: "2023-12-27 10:00:00")
        
        self.result.value = [notice]
    }
}
