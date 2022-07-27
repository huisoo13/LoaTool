//
//  CharacterViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/05.
//

import UIKit

class CharacterViewModel {
    var result = Bindable<Character>()
    var timer: Timer?

    func configure(_ target: UIViewController, search text: String, isMain: Bool = false, showIndicator: Bool = false) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
                
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            if showIndicator { IndicatorView.showLoadingView(target) }
            Parsing.shared.downloadHTML(text, type: [.stats, .equip, .engrave, .gem, .card]) { data, error in
                switch error {
                case .notFound:
                    Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "캐릭터명을 다시 확인해주세요.").present()
                    IndicatorView.hideLoadingView()
                case .websiteInspect:
                    if showIndicator {
                        Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "로스트아크 공식 홈페이지가 점검 중입니다.").present()
                    }
                    IndicatorView.hideLoadingView()
                case .unknown:
                    Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "알 수 없는 오류가 발생했습니다.").present()
                    IndicatorView.hideLoadingView()
                default:
                    Parsing.shared.downloadHTML(parsingSkillWith: text) { skill in
                        IndicatorView.hideLoadingView()
                        
                        if let skill = skill {
                            data?.skill.append(objectsIn: skill)
                        }
                        
                        self.result.value = data
                        
                        if let data = data, isMain {
                            self.updateWithRealm(data)
                        }
                    }
                }
            }
        })
    }
    
    func updateWithRealm(_ data: Character) {
        if let oldData = RealmManager.shared.readAll(Character.self).last {
            debug("[LOATOOL][\(DateManager.shared.currentDate())] 원정대 캐릭터 데이터 이전 : \(oldData.sub.count)개 캐릭터")
            oldData.sub.forEach {
                let sub = Sub()
                
                sub.server = $0.server
                sub.name = $0.name
                sub.level = $0.level
                sub.job = $0.job
                
                data.sub.append(sub)
            }
                        
            if DateManager.shared.calculateDate(oldData.lastUpdated) > 0 {
                debug("[LOATOOL][\(DateManager.shared.currentDate())] 대표 캐릭터 데이터 추가")
                
                data.key = RealmManager.shared.readAll(Character.self).count
                RealmManager.shared.add(data)
            } else {
                debug("[LOATOOL][\(DateManager.shared.currentDate())] 대표 캐릭터 데이터 갱신")
                
                oldData.skill.forEach { RealmManager.shared.delete($0.rune) }
                RealmManager.shared.delete(oldData.info)
                RealmManager.shared.delete(oldData.stats)
                RealmManager.shared.delete(oldData.skill)
                RealmManager.shared.delete(oldData.equip)
                RealmManager.shared.delete(oldData.engrave)
                RealmManager.shared.delete(oldData.gem)
                RealmManager.shared.delete(oldData.card)
                RealmManager.shared.delete(oldData.sub)

                data.key = oldData.key
                data.identifier = oldData.identifier
                
                RealmManager.shared.add(data)
            }
        } else {
            debug("[LOATOOL][\(DateManager.shared.currentDate())] 대표 캐릭터 데이터 추가")
            
            data.key = RealmManager.shared.readAll(Character.self).count
            RealmManager.shared.add(data)
        }
        
        User.shared.name = data.info?.name.components(separatedBy: " ")[safe: 1] ?? ""
    }
}
