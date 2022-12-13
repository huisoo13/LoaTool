//
//  Recipe.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/12.
//

import Foundation

/**
 제작 레시피
 */
struct Recipe {
    var identifier: String
    var category: String
    var name: String
    var cost: Int
    var bundleCount: Int
    var product: Material
    var material: [Material]
    var date: String
    
    /**
     구성 요소
     
     - parameters:
        - identifier: 고유값
        - name: 이름
        - cost: 제작 수수료
        - bundleCount: 1회 생산량
        - product: 결과물 정보
        - material: 재료 목록
        - date: 레시피 등록 시간
     */
    
    func cost(of gold: Int) -> Material {
        return Material(
            identifier: "COST",
            name: "제작 수수료",
            grade: "일반",
            url: "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Money/Money_4.png",
            bundleCount: 1,
            tradeRemainCount: 1,
            yDayAvgPrice: 1,
            recentPrice: 1,
            currentMinPrice: 1,
            neededQuantity: gold,
            date: ""
        )
    }
}

/**
 재료 정보
 */
struct Material {
    var identifier: String
    var name: String
    var grade: String
    var url: String
    var bundleCount: Int
    var tradeRemainCount: Int
    var yDayAvgPrice: Double
    var recentPrice: Int
    var currentMinPrice: Int
    var neededQuantity: Int = 0
    var date: String
    
    /**
     구성 요소
     
     - parameters:
        - identifier: 고유값
        - name: 이름
        - grade: 등급
        - url: 이미지 URL
        - bundleCount: 판매 단위
        - tradeRemainCount: 거래 가능 수
        - yDayAvgPrice: 전일 평균 거래가
        - recentPrice: 최근 거래가
        - currentMinPrice: 현재 최저 거래가
        - neededQuantity: 제작에 필요한 양
        - date: 거래소 정보 갱신 시간
     */
    

}

