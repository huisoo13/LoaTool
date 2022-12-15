//
//  Parsing.swift
//  SwiftSoupSamle
//
//  Created by Trading Taijoo on 2021/10/29.
//

import UIKit
import Alamofire
import SwiftSoup
import SwiftyJSON

class Parsing: NSObject {
    static let shared: Parsing = Parsing()
    
    enum ParsingError {
        case notFound
        case websiteInspect
        case unknown
    }
    
    enum Category {
        case stats
        case equip
        case gem
        case engrave
        case card
    }
    
    func downloadHTML(_ text: String, type: [Parsing.Category], completionHandler: @escaping (Character?, ParsingError?) -> Void) {
        guard let url = "https://lostark.game.onstove.com/Profile/Character/\(text)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            debug("\(#function) : URL Error")
            return
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        debug("캐릭터 데이터 호출")
        
        AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseString { (response) in
            guard let html = response.value else {
                return
            }
            
            do {
                let document: Document = try SwiftSoup.parse(html)
                
                let elements: Elements = try document.select("#lostark-wrapper")
                for element in elements {
                    let isInspection = try element.select("div > p.check_time").text().contains("점검")
                    if isInspection {
                        completionHandler(nil, .websiteInspect)
                        debug("캐릭터 데이터 호출 실패: 로스트아크 공식 홈페이지 점검")
                        return
                    }
                }
                
                if elements.count == 0 {
                    completionHandler(nil, .notFound)
                    debug("캐릭터 데이터 호출 실패: 데이터 없음")
                    
                    return
                }
                
                for element in elements {
                    let user = Character()
                    user.identifier = UUID().uuidString
                    
                    let info = self.parsingCharacterData(element)
                    user.info = info
                    
                    if type.contains(.stats) {
                        let stats = self.parsingStatsData(element)
                        user.stats = stats
                    }
                    
                    if type.contains(.equip) {
                        let equip = self.parsingEquipData(element)
                        user.equip.append(objectsIn: equip)
                    }
                    
                    if type.contains(.engrave) {
                        let engrave = self.parsingEngraveData(element)
                        user.engrave = engrave
                    }
                    
                    if type.contains(.gem) {
                        let gem = self.parsingGemData(element)
                        user.gem.append(objectsIn: gem)
                    }
                    
                    if type.contains(.card) {
                        let card = self.parsingCardData(element)
                        user.card.append(objectsIn: card)
                    }
                    
                    let skill = self.parsingSkillData(element).sorted(by: { ($0.level, $1.type, $1.title) > ($1.level, $0.type, $0.title) })
                    user.skill.append(objectsIn: skill)
                    
                    let etc = self.parsingETCData(element)
                    user.etc = etc
                    
                    user.lastUpdated = DateManager.shared.currentDate()
                    
                    let durationTime = CFAbsoluteTimeGetCurrent() - startTime
                    debug("캐릭터 데이터 호출 완료: \(String(format: "%.4f", durationTime))초")
                    
                    completionHandler(user, nil)
                }
            } catch {
                debug("\(#function): \(error)")
                completionHandler(nil, .unknown)
            }
        }
    }
    
    fileprivate func parsingCharacterData(_ element: Element) -> Info {
        let character = Info()
        
        do {
            let data = try element.select("main > div")
            let name = try data.select("div.profile-character-info > span.profile-character-info__lv").text() + " " + data.select("div.profile-character-info > span.profile-character-info__name").text()
            let server = try data.select("div.profile-character-info > span.profile-character-info__server").text()
            let job = try data.select("div.profile-character-info > img").attr("alt")
            let imageURL = try data.select("#profile-equipment > div.profile-equipment__character > img").attr("src")

            let expedition = try data.select("div.profile-ingame > div.profile-info > div.level-info > div.level-info__expedition > span:nth-child(2)").text().replacingOccurrences(of: "Lv.", with: "")
            let level = try data.select("div.profile-ingame > div.profile-info > div.level-info2 > div.level-info2__item > span:nth-child(2)").text().replacingOccurrences(of: "Lv.", with: "").replacingOccurrences(of: ",", with: "")
            let guild = try data.select("div.profile-ingame > div.profile-info > div.game-info > div.game-info__guild > span:nth-child(2)").text()
            let isMaster = try data.select("div.profile-ingame > div.profile-info > div.game-info > div.game-info__guild > span:nth-child(2) > img").attr("src").contains("guild")
            let town = try data.select("div.profile-ingame > div.profile-info > div.game-info > div.game-info__wisdom > span:nth-child(3)").text()
            let memberList = try element.select("#expand-character-list > ul > li > span > button > span").text().trimmingCharacters(in: .whitespacesAndNewlines)

            character.name = name
            character.server = server
            character.job = job
            character.imageURL = imageURL
            
            character.expedition = Int(expedition) ?? 0
            character.level = Double(level) ?? 0
            character.guild = guild
            character.isMaster = isMaster
            character.town = town
            
            character.memberList = memberList
        } catch {
            debug("\(#function): \(error)")
        }
        
        return character
    }
    
    fileprivate func parsingStatsData(_ element: Element) -> Stats {
        let stats = Stats()
        
        do {
            let profile = try element.select("#profile-ability")
            
            for desc in profile {
                let ability = try desc.select("div.profile-ability-basic > ul > li > span:nth-child(2)").text().components(separatedBy: " ")
                let battle = try desc.select("div.profile-ability-battle > ul > li > span:nth-child(2)").text().components(separatedBy: " ")
                
                stats.attack = Int(ability[safe: 0] ?? "0") ?? 0
                stats.health = Int(ability[safe: 1] ?? "0") ?? 0
                
                stats.critical = Int(battle[safe: 0] ?? "0") ?? 0
                stats.specialization = Int(battle[safe: 1] ?? "0") ?? 0
                stats.domination = Int(battle[safe: 2] ?? "0") ?? 0
                stats.swiftness = Int(battle[safe: 3] ?? "0") ?? 0
                stats.endurance = Int(battle[safe: 4] ?? "0") ?? 0
                stats.expertise = Int(battle[safe: 5] ?? "0") ?? 0
            }
        } catch {
            debug("\(#function): \(error)")
        }
        
        return stats
    }
    
    
    fileprivate func parsingEquipData(_ element: Element) -> [Equip] {
        var equips: [Equip] = []
        
        do {
            let html = try element.select("#profile-ability > script").html()
                .replacingOccurrences(of: "$.Profile = ", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let json = JSON.init(parseJSON: html)
            let data = json["Equip"].filter({ !$0.0.contains("Gem") }).sorted(by: { $0.0 < $1.0 })
            
            data.forEach { key, json in
                let equip = Equip()

                let title = json["Element_000"]["value"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                var category = json["Element_001"]["value"]["leftStr0"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                category = json["Element_011"]["value"].stringValue.contains("[엘라 부여]") ? category + " [엘라]" : category
                
                var level: String? = json["Element_001"]["value"]["leftStr2"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                level = level?.contains("레벨") ?? false ? level?.components(separatedBy: " ")[safe: 2] : nil
                
                var tier = json["Element_001"]["value"]["leftStr2"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).components(separatedBy: " ").last?.replacingOccurrences(of: ")", with: "")
                tier = tier != "" ? tier : nil
                
                let quality = json["Element_001"]["value"]["qualityValue"].intValue
                let grade = json["Element_001"]["value"]["slotData"]["iconGrade"].intValue
                let iconPath = "https://cdn-lostark.game.onstove.com/" + json["Element_001"]["value"]["slotData"]["iconPath"].stringValue
                
                let basic = (json["Element_004"]["value"]["Element_000"].stringValue.contains("기본") || json["Element_004"]["value"]["Element_000"].stringValue.contains("팔찌")
                             ? json["Element_004"]["value"]["Element_001"]
                             : json["Element_005"]["value"]["Element_001"]).stringValue
                    .replacingOccurrences(of: "<BR>", with: "\n", options: .regularExpression, range: nil)
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                
                
                let additional = (json["Element_005"]["value"]["Element_000"].stringValue.contains("추가") || json["Element_005"]["value"]["Element_000"].stringValue.contains("세공")
                                  ? json["Element_005"]["value"]["Element_001"]
                                  : json["Element_006"]["value"]["Element_001"]).stringValue
                    .replacingOccurrences(of: "<BR>", with: "\n", options: .regularExpression, range: nil)
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                
                let isAccessory = json["Element_006"]["type"].stringValue == "IndentStringGroup"
                var engraving: String? = ""
                
                if isAccessory {
                    json["Element_006"]["value"]["Element_000"]["contentStr"].forEach { key, json in
                        
                        engraving! += json["contentStr"].stringValue
                            .replacingOccurrences(of: "<BR>", with: "\n", options: .regularExpression, range: nil)
                            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    }
                }
                
                engraving = engraving == "" ? nil : engraving?.trimmingCharacters(in: .whitespacesAndNewlines)

                equip.title = title
                equip.category = category
                equip.level = Int(level ?? "") ?? 0
                equip.tier = tier
                equip.quality = quality
                equip.grade = grade
                equip.iconPath = iconPath
                equip.basicEffect = basic
                equip.additionalEffect = additional
                equip.engravingEffect = engraving
                
                equips.append(equip)
            }
        } catch {
            debug("\(#function): \(error)")
        }
        
        return equips
    }

    
    fileprivate func parsingSkillData(_ element: Element) -> [Skill] {
        var skills: [Skill] = []
        
        do {
            let html = try element.select("#profile-ability > script").html()
                .replacingOccurrences(of: "$.Profile = ", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let json = JSON.init(parseJSON: html)
            let data = json["Skill"].sorted(by: { $0.0 < $1.0 })
            
            data.forEach { string, json in
                let skill = Skill()
                
                let title = json["Element_000"]["value"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let category = json["Element_001"]["value"]["name"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let type = json["Element_001"]["value"]["level"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let iconPath = "https://cdn-lostark.game.onstove.com/" + json["Element_001"]["value"]["slotData"]["iconPath"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let level = json["Element_003"]["value"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let tripods = json["Element_006"]["value"]
                
                tripods.enumerated().forEach { i, tripod in
                    let name = tripod.1["name"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    let level = tripod.1["tier"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    let _ = "https://cdn-lostark.game.onstove.com/" + tripod.1["slotData"]["iconPath"].stringValue
                    let tripod = (name + " " + level).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    switch i {
                    case 0:
                        skill.tripod1 = tripod == "" ? nil : tripod
                    case 1:
                        skill.tripod2 = tripod == "" ? nil : tripod
                    case 2:
                        skill.tripod3 = tripod == "" ? nil : tripod
                    default:
                        break
                    }
                }
                
                skill.title = title
                skill.category = category
                skill.type = type
                skill.level = level.replacingOccurrences(of: " (최대)", with: "")
                skill.iconPath = iconPath
                
                
                // 룬
                let rune = Rune()
                let runeString = (json["Element_007"]["value"]["Element_000"].stringValue.contains("스킬 룬 효과") ? json["Element_007"]["value"]["Element_001"].stringValue : "").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let _ = json["Element_007"]["value"]["Element_000"].stringValue.contains("보석 효과") ? json["Element_007"]["value"]["Element_001"].stringValue : json["Element_008"]["value"]["Element_001"].stringValue
                
                rune.title = (runeString.components(separatedBy: "]").first ?? "")?.replacingOccurrences(of: "[", with: "") ?? ""
                rune.tooltip = runeString.components(separatedBy: "] ").last ?? ""
                
                switch rune.title {
                case "광분":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_202.png"
                case "단죄":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_198.png"
                case "속행":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_196.png"
                case "수호":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_205.png"
                case "심판":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_201.png"
                case "압도":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_203.png"
                case "정화":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_197.png"
                case "집중":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_200.png"
                case "철벽":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_195.png"
                case "출혈":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_206.png"
                case "풍요":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_204.png"
                case "질풍":
                    rune.iconPath = "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_7_194.png"
                default:
                    break
                }
                
                skill.rune = rune
                skills.append(skill)

                return
            }
            
        } catch {
            debug("\(#function): \(error)")
        }
        
        return skills
    }

    
    fileprivate func parsingEngraveData(_ element: Element) -> Engrave {
        let engrave = Engrave()
        
        do {
            let html = try element.select("#profile-ability > script").html()
                .replacingOccurrences(of: "$.Profile = ", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let json = JSON.init(parseJSON: html)["Engrave"]
            
            let keys = json.dictionaryValue.keys.sorted(by: { $0 < $1 })
            for key in keys {
                var equip = ""
                let equips = json[key].dictionaryValue.sorted(by: { $0 < $1 })
                for data in equips {
                    let type = data.value["type"].stringValue
                    let value = data.value["value"]
                    
                    switch type {
                    case "NameTagBox":
                        let title = value.stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
                        equip += title
                    case "EngraveSkillTitle":
                        let value = value["leftText"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
                        equip += value
                    default:
                        break
                    }
                }
                
                equip = equip.replacingOccurrences(of: "각인 활성 포인트", with: "")
                
                engrave.equips += equip + "\n"
            }
            
            let data = try element.select("#profile-ability > div.profile-ability-engrave > div > div.swiper-wrapper > ul")
            
            for desc in data {
                let title = try desc.select("span").array().map { try $0.text() }
                
                title.forEach{ engrave.effect += $0 + "\n" }
            }
            
            engrave.equips = engrave.equips.trimmingCharacters(in: .whitespacesAndNewlines)
            engrave.effect = engrave.effect.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            debug("\(#function): \(error)")
        }
        
        return engrave
    }
    
    fileprivate func parsingGemData(_ element: Element) -> [Gem] {
        var gems: [Gem] = []
        
        do {
            let html = try element.select("#profile-ability > script").html()
                .replacingOccurrences(of: "$.Profile = ", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let json = JSON.init(parseJSON: html)
            let data = json["Equip"]
            
            
            let keys = data.dictionaryValue.keys.filter { $0.contains("Gem") }.sorted(by: { $0 < $1 })
            for key in keys {
                let gem = Gem()
                
                let options = data[key]
                for option in options.dictionaryValue.sorted(by: { $0 < $1 }) {
                    let type = option.value["type"].stringValue
                    let value = option.value["value"]
                    switch type {
                    case "NameTagBox":
                        let title = value.stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        
                        gem.title = title
                    case "ItemTitle":
                        let level = value["slotData"]["rtString"].stringValue
                        let grade = value["slotData"]["iconGrade"].intValue
                        let iconPath = value["slotData"]["iconPath"].stringValue
                        
                        gem.level = Int(level.replacingOccurrences(of: "Lv.", with: "")) ?? 0
                        gem.grade = grade
                        gem.iconPath = "https://cdn-lostark.game.onstove.com/" + iconPath
                    case "ItemPartBox":
                        if value["Element_000"].stringValue.contains("효과") {
                            let tooltip = value["Element_001"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                            
                            gem.tooltip = tooltip
                        }
                    default:
                        break
                    }
                }
                
                gems.append(gem)
            }
            
        } catch {
            debug("\(#function): \(error)")
        }
        
        return gems
    }
    
    fileprivate func parsingCardData(_ element: Element) -> [Card] {
        var cards: [Card] = []
        
        do {
            let data = try element.select("#cardSetList").select("li")
            
            for desc in data {
                let card = Card()
                
                let title = try desc.select("div.card-effect__title").text()
                let tooltip = try desc.select("div.card-effect__dsc").text()
                
                card.title = title
                card.tooltip = tooltip
                
                cards.append(card)
            }
        } catch {
            debug("\(#function): \(error)")
        }
        
        return cards
    }
    
    fileprivate func parsingETCData(_ element: Element) -> ETC {
        let etc = ETC()
        
        do {
            let html = try element.select("#profile-ability > script").html()
                .replacingOccurrences(of: "$.Profile = ", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let json = JSON.init(parseJSON: html)
            let data = json["Equip"].filter({ !$0.0.contains("Gem") }).sorted(by: { $0.0 < $1.0 })

            let isSetType = data.first?.1["Element_008"]["type"].stringValue.contains("IndentStringGroup") ?? false
            
            
            let types = isSetType ? data.first?.1["Element_008"]["value"]["Element_000"]["contentStr"] : data.first?.1["Element_009"]["value"]["Element_000"]["contentStr"]
            let type = types?.dictionary?.values.map { json in
                return json["contentStr"].stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).components(separatedBy: " ").first ?? ""
            } ?? []
            
            let set = Array(Set(type))
            
            var title = ""
            var piece = ""
            
            set.forEach { string in
                let count = type.filter({ $0 == string }).count
                title += "\(string) "
                piece += "\(count)세트 "
            }
            
            title = title.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
            piece = piece.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")

            let setType = title + "\n" + piece
            etc.setType = setType
            
            let skillPoint = try element.select("#profile-skill > div.profile-skill-battle > div.profile-skill__point").text().replacingOccurrences(of: "트", with: "트 ")
            let usedSkillPoint = Int(skillPoint.components(separatedBy: " / ").first?.components(separatedBy: " ").last ?? "0") ?? 0
            let maxSkillPoint = Int(skillPoint.components(separatedBy: " / ").last?.components(separatedBy: " ").last ?? "0") ?? 0
            
            etc.usedSkillPoint = usedSkillPoint
            etc.maxSkillPoint = maxSkillPoint
        } catch {
            debug("\(#function): \(error)")
        }
        
        return etc
    }

    
    func downloadHTML(parsingSkillWith text: String, completionHandler: @escaping ([Skill]?) -> Void) {
        guard let url = "https://m-lostark.game.onstove.com/Profile/Character/\(text)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            debug("\(#function) : URL Error")
            return
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        debug("스킬 데이터 호출")
        
        AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseString { (response) in
            guard let html = response.value else {
                return
            }
            
            var skills: [Skill] = []
            
            do {
                let document: Document = try SwiftSoup.parse(html)
                
                let elements: Elements = try document.select("#lostark-wrapper")
                for element in elements {
                    let isInspection = try element.select("div > main > div > div > div > p.check_time").text().contains("점검")
                    if isInspection {
                        completionHandler(nil)
                        debug("스킬 데이터 호출 실패: 로스트아크 공식 홈페이지 점검")
                        return
                    }
                }
                
                if elements.count == 0 {
                    completionHandler(nil)
                    debug("스킬 데이터 호출 실패: 데이터 없음")
                    
                    return
                }
                
                for element in elements {
                    let data = try element.select("#profile-skill-battle > div > div.profile-skill__list > div")
                    
                    for desc in data {
                        let skill = Skill()
                        
                        let category = try desc.select("span.profile-skill__category").text()
                        let title = try desc.select("span.profile-skill__title").text()
                        let iconPath = try desc.select("div.profile-skill__slot").select("img").attr("src")
                        let level = try desc.select("div.profile-skill__lv").text()
                        let status = try desc.select("div.profile-skill__status").select("span")
                        let subject = try desc.select("div.profile-skill__subject > div").attr("data-runetooltip")
                        
                        skill.category = category
                        skill.title = title
                        skill.iconPath = iconPath
                        skill.level = level.components(separatedBy: " ").reversed().joined().replacingOccurrences(of: "스킬레벨", with: "스킬레벨 ")
                        
                        for (i, tripod) in status.enumerated() {
                            switch i {
                            case 0:
                                skill.tripod1 = try tripod.text()
                            case 1:
                                skill.tripod2 = try tripod.text()
                            case 2:
                                skill.tripod3 = try tripod.text()
                            default:
                                break
                            }
                        }
                        
                        let rune = Rune()
                        let json = JSON.init(parseJSON: subject)
                        let runes = json.dictionaryValue.sorted(by: { $0 < $1 })
                        for data in runes {
                            let type = data.value["type"].stringValue
                            let value = data.value["value"]
                            
                            switch type {
                            case "NameTagBox":
                                let title = value.stringValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                
                                rune.title = title
                            case "ItemTitle":
                                let grade = value["slotData"]["iconGrade"].intValue
                                let iconPath = value["slotData"]["iconPath"].stringValue
                                
                                rune.grade = grade
                                rune.iconPath = "https://cdn-lostark.game.onstove.com/" + iconPath
                            case "ItemPartBox":
                                let tooltip = value["Element_001"].stringValue
                                
                                rune.tooltip = tooltip
                            default:
                                break
                            }
                        }
                        
                        if rune.title != "" {
                            skill.rune = rune
                        }
                        
                        skills.append(skill)
                    }
                    
                    let durationTime = CFAbsoluteTimeGetCurrent() - startTime
                    debug("스킬 데이터 호출 완료: \(String(format: "%.4f", durationTime))초")
                    
                    completionHandler(skills)
                }
            } catch {
                debug("\(#function): \(error)")
            }
        }
    }
    
    func downloadHTML(parsingMemberListWith text: [String], completionHandler: @escaping ([Sub]?) -> Void) {
        if text.count <= 0 { return }
        
        var subs: [Sub] = []
        let startTime = CFAbsoluteTimeGetCurrent()
        debug("보유 캐릭터 데이터 호출")
        
        text.forEach {
            guard let url = "https://m-lostark.game.onstove.com/Profile/Character/\($0)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                debug("\(#function) : URL Error")
                return
            }
            
            AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseString { (response) in
                guard let html = response.value else {
                    return
                }
                
                do {
                    let document: Document = try SwiftSoup.parse(html)
                    
                    let elements: Elements = try document.select("#lostark-wrapper")
                    for element in elements {
                        let sub = Sub()
                        let data = try element.select("div.myinfo__contents-character")
                        
                        let name = try data.select("#myinfo__character--button2").text()
                        let info = try data.select("dl.myinfo__user-names > dd > div.wrapper-define > dl > dd").text().components(separatedBy: " ")
                        let level = try data.select("div.myinfo__contents-level > div:nth-child(2) > dl.define.item > dd").text().replacingOccurrences(of: ",", with: "")
                        
                        sub.server = info.first ?? ""
                        sub.job = info.last ?? "알수없음"
                        sub.name = name
                        sub.level = Double(level) ?? 0
                        
                        subs.append(sub)
                        
                        if text.count == subs.count {
                            let durationTime = CFAbsoluteTimeGetCurrent() - startTime
                            debug("보유 캐릭터 데이터 호출 완료: \(String(format: "%.4f", durationTime))초")
                            
                            subs.sort(by: { ($0.server, $1.level, $0.name) < ($1.server, $0.level, $1.name) })
                            completionHandler(subs)
                        }
                    }
                } catch {
                    debug("\(#function): \(error)")
                    completionHandler(nil)
                }
            }
        }
    }
    
    func downloadHTMLForAD(completionHandler: @escaping ([AD]) -> Void) {
        guard let url = "https://www.smilegatefoundation.org/hope/index"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            debug("\(#function) : URL Error")
            return
        }
        
        AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseString { (response) in
            guard let html = response.value else {
                return
            }
            
            var ad: [AD] = []
            
            do {
                let document: Document = try SwiftSoup.parse(html)
                
                let elements: Elements = try document.select("#container")
                for element in elements {
                    let array = try element.select("div.swiper-wrapper > div")
                    for data in array {
                        let thumb = try data.select("img").attr("src")
                        let url = try data.select("div.thumb > a").attr("href")
                        let title = try data.select("div.txt > span.subj").text()
                        
                        if title != "" {
                            ad.append(AD(URL: "https://www.smilegatefoundation.org" + url, imageURL: thumb, title: title))
                        }
                    }
                }
                
                
                
                completionHandler(ad)
            } catch {
                debug("\(#function): \(error)")
            }
        }
    }
}


