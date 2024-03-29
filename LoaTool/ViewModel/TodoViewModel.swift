//
//  TodoViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/12.
//

import UIKit
import RealmSwift

class TodoViewModel {
    var result = Bindable<Todo>()
    var isNil = Bindable<Bool>()
    
    func configure() {
        guard let data = RealmManager.shared.readAll(Todo.self).first else {
            self.isNil.value = true
            return
        }
        
        self.isNil.value = false
        self.result.value = updateWithRealm(data)
        
    }
    
    func updateWithRealm(_ data: Todo) -> Todo {
        let calculate = DateManager.shared.calculateDate(data.lastUpdate)
        
        self.sortedIncludedMember()
        self.updateCompletedMember()
        
        if calculate > 0 {
            self.updateDailyContent(data, calculate: calculate)
            self.updateWeeklyContent(data)
        }
            
        RealmManager.shared.update {
            data.lastUpdate = DateManager.shared.currentDate()
            data.nextLoaWeekday = DateManager.shared.nextLoaWeekday(DateManager.shared.currentDate())
        }

        return data
    }
    
    
    fileprivate func updateDailyContent(_ todo: Todo, calculate: Int) {
        debug("일일 컨텐츠 갱신")
        
        if let island = todo.member.first?.contents.last {
            RealmManager.shared.update {
                island.maxValue = island.weekday.contains(DateManager.shared.currentWeekday()) ? 2 : 1
            }
        }
        
        todo.member.forEach { member in
            member.contents.forEach { content in
                RealmManager.shared.update {
                    content.bonusValue += ((content.maxValue * (calculate - 1)) + (content.maxValue - content.value)) * 10
                    content.bonusValue = max(0, min(content.bonusValue, 100))
                    content.originBonusValue = content.bonusValue
                    
                    content.value = 0
                }
            }
        }
        
        todo.additional.forEach { content in
            if content.type < 20 {
                RealmManager.shared.update {
                    content.completed.removeAll()
                    content.takenGold.removeAll()
                }
            }
        }
    }
    
    fileprivate func updateWeeklyContent(_ todo: Todo) {
        if todo.nextLoaWeekday < DateManager.shared.nextLoaWeekday(DateManager.shared.currentDate()) {
            debug("주간 컨텐츠 갱신")

            todo.additional.forEach { content in
                RealmManager.shared.update {
                    content.completed.removeAll()
                    content.takenGold.removeAll()
                }
            }
        }
    }
    
    fileprivate func sortedIncludedMember() {
        guard let todo = RealmManager.shared.readAll(Todo.self).first else { return }

        let members = todo.member
        let contents = todo.additional
        
        RealmManager.shared.update {
            contents.forEach { content in
                var included: [String] = []
                
                members.forEach { member in
                    content.included.forEach { identifier in
                        if member.identifier == identifier {
                            included.append(identifier)
                        }
                    }
                }
 
                content.included.removeAll()
                content.included.append(objectsIn: included)
            }
        }
    }
    
    fileprivate func updateCompletedMember() {
        guard let todo = RealmManager.shared.readAll(Todo.self).first else { return }

        let contents = todo.additional

        RealmManager.shared.update {
            contents.forEach { content in
                let included = content.included
                let completed = content.completed
                let takenGold = content.takenGold

                completed.enumerated().forEach { i, member in
                    if !included.contains(member) {
                        completed.remove(at: i)
                        takenGold.remove(at: i)
                    }
                }
            }
        }
    }
    
    func updateContentManually() {
        guard let data = self.result.value else { return }
        let calculate = DateManager.shared.calculateDate(data.lastUpdate)

        self.sortedIncludedMember()
        self.updateCompletedMember()
                
        data.additional.forEach { content in
            RealmManager.shared.update {
                content.completed.removeAll()
                content.takenGold.removeAll()
            }
        }

        RealmManager.shared.update {
            data.lastUpdate = DateManager.shared.currentDate()
            data.nextLoaWeekday = DateManager.shared.nextLoaWeekday(DateManager.shared.currentDate())
        }
    }
    
    func updateMemberInfo() {
        guard let todo = self.result.value else { return }

        let memberList = Array(todo.member.filter({ $0.category != 0 }).map { $0.name })
        
        IndicatorView.showLoadingView()
        Parsing.shared.downloadHTML(parsingMemberListWith: memberList) { data in
            let member = todo.member
            
            member.forEach { member in
                data?.forEach({ sub in
                    if member.name == sub.name.components(separatedBy: " ").last ?? "" {
                        RealmManager.shared.update {
                            member.level = sub.level
                            member.job = sub.job
                        }
                    }
                })
            }
            
            IndicatorView.hideLoadingView()
            self.configure()
        }
    }
}
