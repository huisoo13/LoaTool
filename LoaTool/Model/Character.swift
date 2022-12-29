//
//  Character.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/02/25.
//

import UIKit
import RealmSwift

/**
 캐릭터 정보 모델
 */
class Character: Object {
    @objc dynamic var key: Int = 0
    @objc dynamic var identifier: String = ""

    @objc dynamic var info: Info?
    @objc dynamic var stats: Stats?
    @objc dynamic var engrave: Engrave?

    var equip = List<Equip>()
    var skill = List<Skill>()
    var card = List<Card>()
    var gem = List<Gem>()
    var sub = List<Sub>()

    @objc dynamic var etc: ETC? = ETC()
    @objc dynamic var lastUpdated: String = ""

    override class func primaryKey() -> String? {
        return "key"
    }
    
    override init() {
        super.init()
    }
    
    /**
     구성 요소
     
     - parameters:
        - key: 고유아이디
        - identifier: 고유값
     
        - info: 기본 정보
        - stats: 능력치
        - equip: 장비
        - engrave: 각인
        - skill: 스킬
        - card: 카드
        - gem: 보석
        - sub: 보유 캐릭터 정보
     
        - etc: 기타 정보
        - lastUpdated: 최종 갱신일
     */
}

/**
 캐릭터 기본 정보 모델
 */
class Info: Object {
    @objc dynamic var server: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var job: String = ""
    @objc dynamic var level: Double = 0
    @objc dynamic var expedition: Int = 0
    @objc dynamic var guild: String = ""
    @objc dynamic var isMaster: Bool = false
    @objc dynamic var town: String = ""
    @objc dynamic var imageURL: String = ""

    @objc dynamic var memberList: String = ""

    var parent = LinkingObjects(fromType: Character.self, property: "info")

    /**
     구성 요소
     
     - parameters:
        - server: 서버
        - name: 이름
        - job: 직업명
        - level: 아이템 레벨
        - expedition: 원정대 레벨
        - guild: 길드명
        - isMaster: 길드마스터 여부
        - town: 영지명
     
        - memberList: 보유 캐릭터 목록
     */
}

/**
 캐릭터 능력치 정보 모델
 */
class Stats: Object {
    @objc dynamic var attack: Int = 0
    @objc dynamic var health: Int = 0
    
    @objc dynamic var critical: Int = 0
    @objc dynamic var specialization: Int = 0
    @objc dynamic var domination: Int = 0
    @objc dynamic var swiftness: Int = 0
    @objc dynamic var endurance: Int = 0
    @objc dynamic var expertise: Int = 0
    
    var parent = LinkingObjects(fromType: Character.self, property: "stats")

    /**
     구성 요소
     
     - parameters:
        - attack: 공격력
        - health: 생명력
     
        - critical: 치명
        - specialization: 특화
        - domination: 제압
        - swiftness: 신속
        - endurance: 인내
        - expertise: 숙련
     */
}

/**
 캐릭터 장비 정보 모델
 */
class Equip: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var level: Int = 0
    @objc dynamic var tier: String?
    @objc dynamic var quality: Int = 0
    @objc dynamic var grade: Int = 0
    @objc dynamic var iconPath: String = ""
    @objc dynamic var basicEffect: String?
    @objc dynamic var additionalEffect: String?
    @objc dynamic var engravingEffect: String?
    
    var parent = LinkingObjects(fromType: Character.self, property: "equip")
    
    /**
     구성 요소
     
     - parameters:
        - name: 아이템명
        - category: 부위
        - tier: 티어
        - quality: 품질
        - grade: 등급
        - iconPath: 아이콘
        - basicEffect: 기본 옵션
        - additionalEffect: 추가 옵션
        - engravingEffect: 각인
     */
}

/**
 캐릭터 각인 정보 모델
 */
class Engrave: Object {
    @objc dynamic var equips: String = ""
    @objc dynamic var effect: String = ""
    
    var parent = LinkingObjects(fromType: Character.self, property: "engrave")

    /**
     구성 요소
     
     - parameters:
        - equips: 착용 각인
        - effect: 적용 각인
     */
}

/**
 캐릭터 스킬 정보 모델
 */
class Skill: Object {
    @objc dynamic var type: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var iconPath: String = ""
    @objc dynamic var level: String = ""
    @objc dynamic var tripod1: String?
    @objc dynamic var tripod2: String?
    @objc dynamic var tripod3: String?
    
    @objc dynamic var rune: Rune?
    
    var parent = LinkingObjects(fromType: Character.self, property: "skill")
    
    /**
     구성 요소
     
     - parameters:
        - type: 일반 / 각성
        - category: 종류
        - title: 스킬명
        - level: 스킬 레벨
        - iconPath: 아이콘
        - tripod1: 트라이포드 1
        - tripod2: 트라이포드 2
        - tripod3: 트라이포드 3
        - rune: 룬
     */
}

/**
 캐릭터 스킬 룬 정보 모델
 */
class Rune: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var grade: Int = 0
    @objc dynamic var iconPath: String = ""
    @objc dynamic var tooltip: String = ""
    
    var parent = LinkingObjects(fromType: Skill.self, property: "rune")
    
    /**
     구성 요소
     
     - parameters:
        - title: 룬명
        - grade: 등급
        - iconPath: 아이콘
        - tooltip: 설명
     */
}

/**
 캐릭터 카드 정보 모델
 */
class Card: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var tooltip: String = ""
    
    var parent = LinkingObjects(fromType: Character.self, property: "card")
    
    /**
     구성 요소
     
     - parameters:
        - title: 효과명
        - tooltip: 설명
     */
}

/**
 캐릭터 보석 정보 모델
 */
class Gem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var level: Int = 0
    @objc dynamic var grade: Int = 0
    @objc dynamic var iconPath: String = ""
    @objc dynamic var tooltip: String = ""
    
    var parent = LinkingObjects(fromType: Character.self, property: "gem")
    
    /**
     구성 요소
     
     - parameters:
        - title: 보석명
        - level: 레벨
        - grade: 등급
        - iconPath: 아이콘
        - tooltip: 설명
     */
    
    override init() {
        super.init()
    }
    
    init(title: String, level: Int, grade: Int, iconPath: String, tooltip: String) {
        self.title = title
        self.level = level
        self.grade = grade
        self.iconPath = iconPath
        self.tooltip = tooltip
    }
}

/**
 캐릭터 기타 정보
 */
class ETC: Object {
    @objc dynamic var setType: String = ""
    @objc dynamic var maxSkillPoint: Int = 0
    @objc dynamic var usedSkillPoint: Int = 0
    

    var parent = LinkingObjects(fromType: Character.self, property: "etc")
    
    /**
     구성 요소
     
     - parameters:
        - setType: 장비 세트 옵션
        - maxSkillPoint: 보유 스킬 포인트
        - usedSkillPoint: 사용 스킬 포인트
     */
    
    override init() {
        super.init()
    }
    
    init(setType: String, maxSkillPoint: Int, usedSkillPoint: Int) {
        self.setType = setType
        self.maxSkillPoint = maxSkillPoint
        self.usedSkillPoint = usedSkillPoint
    }
}

/**
 보유 캐릭터 정보 모델
 */
class Sub: Object {
    @objc dynamic var server: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var job: String = ""
    @objc dynamic var level: Double = 0
    
    var parent = LinkingObjects(fromType: Character.self, property: "sub")
    
    /**
     구성 요소
     
     - parameters:
        - server: 서버
        - name: 캐릭터명
        - job: 직업
        - level: 레벨
     */
}
