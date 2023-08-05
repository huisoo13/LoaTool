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
                               level: 1620,
                               server: "@아만",
                               text: "안녕하세요. 로아툴 개발자입니다.\n\n현재 AWS 이용 중 비정상적인 데이터 사용이 발생하여 해당 문제를 수정하기 전까지 관련 서비스를 일시 중지하였습니다.\n관련 서비스는 본인인증, 커뮤니티 및 제작 효율표가 해당됩니다.\n\n현생이 힘들어서 업데이트가 늦을 예정이지만 이후 업데이트 예정 사항은 캐릭별 비프로스트 메모, 내실 내역 등이 있습니다.\n\n관리도 제대로 못하고있는데 아직도 사용해주시고 계신분들 정말 감사합니다!",
                               imageURL: [],
                               gateway: "",
                               numberOfLiked: 0,
                               numberOfComment: 0,
                               isLiked: false,
                               isMarked: false,
                               date: "2023-06-04 10:00:00")
        
        self.result.value = [notice]
    }
}
