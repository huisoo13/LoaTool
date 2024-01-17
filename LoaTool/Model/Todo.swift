//
//  Todo.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/02/25.
//

import UIKit
import RealmSwift

/**
 컨텐츠 관리 모델
 */
class Todo: Object {
    @objc dynamic var identifier: String = UUID().uuidString
    @objc dynamic var lastUpdate: String = ""
    @objc dynamic var nextLoaWeekday: String = ""
    
    var member = List<Member>()
    var additional = List<AdditionalContent>()
    var gold = List<String>()
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    override init() {
        super.init()
    }
    
    /**
     구성 요소
     
     - parameters:
     - key: 고유아이디
     - identifier: 고유값
     - lastUpdate: 마지막 업데이트
     - nextLoaWeekday: 다음 로요일
     - member: 캐릭터
     - extra: 추가 컨텐츠
     */

}

/**
 캐릭터 모델
 */
class Member: Object, NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
    
    @objc dynamic var identifier: String = UUID().uuidString
    @objc dynamic var category: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var job: String = ""
    @objc dynamic var level: Double = 0
    @objc dynamic var cube: Int = 0
    @objc dynamic var boss: Int = 0

    var contents = List<Content>()
    
    var parent = LinkingObjects(fromType: Todo.self, property: "member")
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    override init() {
        super.init()
    }
    
    /**
     구성 요소
     
     - parameters:
     - identifier: 고유아이디
     - category: 0: 원정대 / 1: 캐릭터
     - name: 캐릭터명
     - job: 직업
     - level: 레벨
     - contents: 컨텐츠 현황
     */
    
    init(identifier: String, category: Int, name: String, job: String, level: Double, contents: [Content]) {
        self.identifier = identifier
        self.category = category
        self.name = name
        self.job = job
        self.level = level
        
        self.contents.removeAll()
        self.contents.append(objectsIn: contents)
    }
    
    static var expedition = Member(identifier: UUID().uuidString,
                                   category: 0,
                                   name: "원정대",
                                   job: "원정대",
                                   level: 0,
                                   contents: Content.expedition
    )
}

/**
 일반 컨텐츠 모델
 */
class Content: Object {
    @objc dynamic var identifier: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var icon: Int = 0
    
    @objc dynamic var value: Int = -1
    @objc dynamic var maxValue: Int = -1
    @objc dynamic var bonusValue: Int = 0
    @objc dynamic var minBonusValue: Int = 0
    @objc dynamic var originBonusValue: Int = 0
    
    var weekday = List<Int>()
    
    var parent = LinkingObjects(fromType: Member.self, property: "contents")
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    override init() {
        super.init()
    }
    
    /**
     구성 요소
     
     - parameters:
     - identifier: 고유아이디
     - title: 컨텐츠 이름
     - icon: 아이콘
     - value: 현재값
     - maxValue: 최대값
     - bonusValue: 보너스
     - minBonusValue: 최소 보너스
     - originBonusValue: 기존 보너스
     - weekday: 요일
     */
    init(identifier: String, title: String, icon: Int, value: Int, maxValue: Int, bonusValue: Int, minBonusValue: Int, originBonusValue: Int, weekday: [Int]) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.value = value
        self.maxValue = maxValue
        self.bonusValue = bonusValue
        self.minBonusValue = minBonusValue
        self.originBonusValue = originBonusValue
        self.weekday.removeAll()
        self.weekday.append(objectsIn: weekday)
    }
    
    static let character: [Content] = [Content(identifier: UUID().uuidString,
                                               title: "가디언 토벌",
                                               icon: 6,
                                               value: 0,
                                               maxValue: 1,
                                               bonusValue: 0,
                                               minBonusValue: 0,
                                               originBonusValue: 0,
                                               weekday: [1, 2, 3, 4, 5, 6, 7]),
                                       Content(identifier: UUID().uuidString,
                                               title: "카오스 던전",
                                               icon: 8,
                                               value: 0,
                                               maxValue: 2,
                                               bonusValue: 0,
                                               minBonusValue: 0,
                                               originBonusValue: 0,
                                               weekday: [1, 2, 3, 4, 5, 6, 7]),
                                       Content(identifier: UUID().uuidString,
                                               title: "에포나 의뢰",
                                               icon: 0,
                                               value: 0,
                                               maxValue: 3,
                                               bonusValue: 0,
                                               minBonusValue: 0,
                                               originBonusValue: 0,
                                               weekday: [1, 2, 3, 4, 5, 6, 7])
    ]
    
    static let expedition: [Content] = [Content(identifier: UUID().uuidString,
                                                title: "필드 보스",
                                                icon: 11,
                                                value: 0,
                                                maxValue: 1,
                                                bonusValue: 0,
                                                minBonusValue: 0,
                                                originBonusValue: 0,
                                                weekday: [1, 3, 6]),
                                        Content(identifier: UUID().uuidString,
                                                title: "카오스 게이트",
                                                icon: 10,
                                                value: 0,
                                                maxValue: 1,
                                                bonusValue: 0,
                                                minBonusValue: 0,
                                                originBonusValue: 0,
                                                weekday: [1, 2, 5, 7]),
                                        Content(identifier: UUID().uuidString,
                                                title: "모험섬",
                                                icon: 24,
                                                value: 0,
                                                maxValue: 1,
                                                bonusValue: 0,
                                                minBonusValue: 0,
                                                originBonusValue: 0,
                                                weekday: [1, 7])
    ]
}

/**
 추가 컨텐츠 모델
 */
class AdditionalContent: Object, NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
    
    @objc dynamic var identifier: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var type: Int = 10
    @objc dynamic var icon: Int = 0
    @objc dynamic var level: Double = 0
    @objc dynamic var limit: Double = 0
    @objc dynamic var allowLimit: Bool = false
    @objc dynamic var gold: Int = 0
    @objc dynamic var link: String = ""
    @objc dynamic var gate: String = ""

    var included = List<String>()
    var completed = List<String>()
    var takenGold = List<String>()
    var weekday = List<Int>()
    
    var parent = LinkingObjects(fromType: Todo.self, property: "additional")
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    override init() {
        super.init()
    }
    
    /**
     구성 요소
     
     - parameters:
     - identifier: 고유아이디
     - title: 컨텐츠 이름
     - type: 일일 / 주간 / 어비스 / 엔드 컨텐츠 / 기타
     - icon: 아이콘
     - level: 컨텐츠 제한 레벨
     - limit: 골드 획득 제한 레벨
     - allowLimit: 골드 획득 제한 사용
     - gold: 획득 골드
     - link: 연결 (동일 군단장 식별)
     - gate: 관문 (동일 관문 식별)
     - included: 미완료 캐릭터
     - completed: 완료 캐릭터
     - weekday: 요일
     */
    init(identifier: String, title: String, type: Int, icon: Int, level: Double, limit: Double = 0, allowLimit: Bool = false, gold: Int, link: String = "", gate: String = "", included: [String], completed: [String], takenGold: [String], weekday: [Int]) {
        self.identifier = identifier
        self.title = title
        self.type = type
        self.icon = icon
        self.level = level
        self.limit = limit
        self.allowLimit = allowLimit
        self.gold = gold
        self.link = link
        self.gate = gate

        self.included.removeAll()
        self.included.append(objectsIn: included)
        
        self.completed.removeAll()
        self.completed.append(objectsIn: completed)
        
        self.takenGold.removeAll()
        self.takenGold.append(objectsIn: completed)

        self.weekday.removeAll()
        self.weekday.append(objectsIn: weekday)
    }
    
    static var preset: [AdditionalContent] = [AdditionalContent(identifier: "PRESET-001",
                                                                title: "도전 가디언 토벌",
                                                                type: 20,
                                                                icon: 6,
                                                                level: 460,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-002",
                                                                title: "도전 어비스 던전",
                                                                type: 20,
                                                                icon: 3,
                                                                level: 460,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-003",
                                                                title: "주간 에포나 의뢰",
                                                                type: 21,
                                                                icon: 1,
                                                                level: 460,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-004",
                                                                title: "툴루비크",
                                                                type: 20,
                                                                icon: 32,
                                                                level: 1445,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 4, 7]),
//                                              AdditionalContent(identifier: "PRESET-005",
//                                                                title: "유령선",
//                                                                type: 20,
//                                                                icon: 18,
//                                                                level: 460,
//                                                                gold: 0,
//                                                                included: [],
//                                                                completed: [],
//                                                                takenGold: [],
//                                                                weekday: [3, 5, 7]),
                                              AdditionalContent(identifier: "PRESET-006",
                                                                title: "길드 출석",
                                                                type: 11,
                                                                icon: 17,
                                                                level: 0,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-007",
                                                                title: "어비스 던전",
                                                                type: 31,
                                                                icon: 2,
                                                                level: 0,
                                                                gold: 0,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-008",
                                                                title: "[노말] 카양겔",
                                                                type: 31,
                                                                icon: 2,
                                                                level: 1475,
                                                                gold: 4500,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-009",
                                                                title: "[하드] 카양겔",
                                                                type: 31,
                                                                icon: 2,
                                                                level: 1520,
                                                                gold: 6500,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
//                                              AdditionalContent(identifier: "PRESET-010",
//                                                                title: "[하드2] 카양겔",
//                                                                type: 31,
//                                                                icon: 2,
//                                                                level: 1560,
//                                                                gold: 0,
//                                                                included: [],
//                                                                completed: [],
//                                                                takenGold: [],
//                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
//                                              AdditionalContent(identifier: "PRESET-011",
//                                                                title: "[하드3] 카양겔",
//                                                                type: 31,
//                                                                icon: 2,
//                                                                level: 1580,
//                                                                gold: 0,
//                                                                included: [],
//                                                                completed: [],
//                                                                takenGold: [],
//                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-012",
                                                                title: "아르고스",
                                                                type: 31,
                                                                icon: 7,
                                                                level: 1370,
                                                                limit: 1475,
                                                                allowLimit: true,
                                                                gold: 1000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-013",
                                                                title: "[노말] 발탄",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1415,
                                                                gold: 1200,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-014",
                                                                title: "[하드] 발탄",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1445,
                                                                gold: 1800,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-015",
                                                                title: "[노말] 비아키스",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1430,
                                                                gold: 1600,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-016",
                                                                title: "[하드] 비아키스",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1460,
                                                                gold: 2400,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-017",
                                                                title: "[노말] 쿠크세이튼",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1475,
                                                                gold: 3000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-018-1",
                                                                title: "[노말] 아브렐슈드 1-2",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1490,
                                                                gold: 3000,
                                                                link: "LINK-001",
                                                                gate: "GATE-001",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-018-2",
                                                                title: "[노말] 아브렐슈드 3",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1500,
                                                                gold: 1500,
                                                                link: "LINK-001",
                                                                gate: "GATE-002",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-018-3",
                                                                title: "[노말] 아브렐슈드 4",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1520,
                                                                gold: 2500,
                                                                link: "LINK-001",
                                                                gate: "GATE-003",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-019-1",
                                                                title: "[하드] 아브렐슈드 1-2",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1540,
                                                                gold: 4000,
                                                                link: "LINK-001",
                                                                gate: "GATE-001",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-019-2",
                                                                title: "[하드] 아브렐슈드 3",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1550,
                                                                gold: 2000,
                                                                link: "LINK-001",
                                                                gate: "GATE-002",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-019-3",
                                                                title: "[하드] 아브렐슈드 4",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1560,
                                                                gold: 3000,
                                                                link: "LINK-001",
                                                                gate: "GATE-003",
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-020",
                                                                title: "[노말] 일리아칸",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1580,
                                                                gold: 7500,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-021",
                                                                title: "[하드] 일리아칸",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1600,
                                                                gold: 10000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-022",
                                                                title: "[노말] 혼돈의 상아탑",
                                                                type: 41,
                                                                icon: 2,
                                                                level: 1600,
                                                                gold: 9000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-023",
                                                                title: "[하드] 혼돈의 상아탑",
                                                                type: 41,
                                                                icon: 2,
                                                                level: 1620,
                                                                gold: 14500,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-024",
                                                                title: "[노말] 카멘 1-3",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1610,
                                                                gold: 14500,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-025",
                                                                title: "[하드] 카멘 1-3",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1630,
                                                                gold: 20000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              AdditionalContent(identifier: "PRESET-026",
                                                                title: "[하드] 카멘 4",
                                                                type: 41,
                                                                icon: 9,
                                                                level: 1630,
                                                                gold: 21000,
                                                                included: [],
                                                                completed: [],
                                                                takenGold: [],
                                                                weekday: [1, 2, 3, 4, 5, 6, 7]),
                                              
    ]
}
