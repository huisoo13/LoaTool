//
//  Party.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/24.
//

import UIKit

/**
 파티 구성 모델
 */
struct Party {
    var key: Int = 0
    var identifier: String = ""
    var target: Int = 0
    var category: Int = 0
    var numberOfMember: Int = 0
    var numberOfAttacker: Int = 0
    var numberOfSupporter: Int = 0
    var numberOfSpecialist: Int = 0
    var members: [PartyMember] = []
    var startDate: String = ""
    var lastUpdated: String = ""
    
    /**
     구성 요소
     
     - parameters:
        - key: 고유아이디
        - identifier: 고유값
        - target: 목표물
        - category: 분류
        - numberOfMember: 최대 인원
        - numberOfAttacker: 공격 담당 인원
        - numberOfSupporter: 보조 담당 인원
        - numberOfSpecialist: 특임 담당 인원
        - status: 상태
        - startDate: 출발 시간
        - lastUpdated: 최종 갱신일
     */
}

struct PartyMember {
    var identifier: String = ""
    var delegator: String = ""
    var type: Int = 0
    var name: String = ""
    var job: String = ""
    var level: Double = 0

    /**
     구성 요소
     
     - parameters:
        - identifier: 고유값
        - delegator: 대표자
        - type: 분류
        - name: 이름
        - job: 직업
        - level: 레벨
     */
}
