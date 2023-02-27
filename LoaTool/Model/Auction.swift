//
//  Auction.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/06.
//

import UIKit

class AuctionRequest {
    var itemLevelMin: Int
    var itemLevelMax: Int
    var itemGradeQuality: Int
    var skillOptions: [RequestOption]
    var etcOptions: [RequestOption]
    var sort: String = "BIDSTART_PRICE"
    var categoryCode: Int
    var characterClass: String
    var itemTier: Int
    var itemGrade: String
    var itemName: String
    var pageNo: Int
    var sortCondition: String = "ASC"

    init(itemLevelMin: Int,
         itemLevelMax: Int,
         itemGradeQuality: Int,
         skillOptions: [RequestOption],
         etcOptions: [RequestOption],
         sort: String = "BIDSTART_PRICE",
         categoryCode: Int,
         characterClass: String,
         itemTier: Int,
         itemGrade: String,
         itemName: String,
         pageNo: Int,
         sortCondition: String = "ASC") {
        self.itemLevelMin = itemLevelMin
        self.itemLevelMax = itemLevelMax
        self.itemGradeQuality = itemGradeQuality
        self.skillOptions = skillOptions
        self.etcOptions = etcOptions
        self.sort = sort
        self.categoryCode = categoryCode
        self.characterClass = characterClass
        self.itemTier = itemTier
        self.itemGrade = itemGrade
        self.itemName = itemName
        self.pageNo = pageNo
        self.sortCondition = sortCondition
    }
    
    func toDictionary() -> [String: Any] {
        return ["ItemLevelMin": itemLevelMin,
                "ItemLevelMax": itemLevelMax,
                "ItemGradeQuality": itemGradeQuality,
                "SkillOptions": skillOptions.map { $0.toDictionary() },
                "EtcOptions": etcOptions.map { $0.toDictionary() },
                "Sort": sort,
                "CategoryCode": categoryCode,
                "CharacterClass": characterClass,
                "ItemTier": itemTier,
                "ItemGrade": itemGrade,
                "ItemName": itemName,
                "PageNo": pageNo,
                "SortCondition": sortCondition]
    }
}

class RequestOption {
    var firstOption: Int
    var secondOption: Int
    var minValue: Int
    var maxValue: Int
    
    init(firstOption: Int, secondOption: Int, minValue: Int, maxValue: Int) {
        self.firstOption = firstOption
        self.secondOption = secondOption
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    func toDictionary() -> [String: Any] {
        return ["FirstOption": firstOption,
                "SecondOption": secondOption,
                "MinValue": minValue,
                "MaxValue": maxValue]
    }
}

class AuctionResponse {
    var pageNo: Int
    var pageSize: Int
    var totalCount: Int
    var items: [ResponseItem]
    
    init(pageNo: Int,
         pageSize: Int,
         totalCount: Int,
         items: [ResponseItem]) {
        self.pageNo = pageNo
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.items = items
    }
}

class ResponseItem {
    var name: String
    var grade: String
    var tier: Int
    var level: Int
    var icon: String
    var gradeQuality: Int
    var auctionInfo: ResponseInfo
    var options: [ResponseOption]
    
    init(name: String,
         grade: String,
         tier: Int,
         level: Int,
         icon: String,
         gradeQuality: Int,
         auctionInfo: ResponseInfo,
         options: [ResponseOption]) {
        self.name = name
        self.grade = grade
        self.tier = tier
        self.level = level
        self.icon = icon
        self.gradeQuality = gradeQuality
        self.auctionInfo = auctionInfo
        self.options = options
    }
    
}

class ResponseInfo {
    var startPrice: Int
    var buyPrice: Int
    var bidPrice: Int
    var endDate: String
    var bidCount: Int
    var bidStartPrice: Int
    var isCompetitive: Bool
    var tradeAllowCount: Int

    init(startPrice: Int,
         buyPrice: Int,
         bidPrice: Int,
         endDate: String,
         bidCount: Int,
         bidStartPrice: Int,
         isCompetitive: Bool,
         tradeAllowCount: Int) {
        self.startPrice = startPrice
        self.buyPrice = buyPrice
        self.bidPrice = bidPrice
        self.endDate = endDate
        self.bidCount = bidCount
        self.bidStartPrice = bidStartPrice
        self.isCompetitive = isCompetitive
        self.tradeAllowCount = tradeAllowCount
    }
}

class ResponseOption {
    var type: String
    var optionName: String
    var optionNameTripod: String
    var value: Int
    var isPenalty: Bool
    var className: String

    init(type: String,
         optionName: String,
         optionNameTripod: String,
         value: Int,
         isPenalty: Bool,
         className: String) {
        self.type = type
        self.optionName = optionName
        self.optionNameTripod = optionNameTripod
        self.value = value
        self.isPenalty = isPenalty
        self.className = className
    }
}
