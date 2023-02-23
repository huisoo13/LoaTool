//
//  Calculator.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/08.
//

import UIKit

class Calculator {
    private let numberOfMaxEngraving: Int = 7

    var targetEngraving: Array<(key: String, value: Int)> = []
    var equipEngraving: Array<(key: String, value: Int)> = []
    var abillityStone: Array<(key: String, value: Int)> = []
    var necklace: Accessory
    var earring1: Accessory
    var earring2: Accessory
    var ring1: Accessory
    var ring2: Accessory

    init(targetEngraving: Array<(key: String, value: Int)>,
         equipEngraving: Array<(key: String, value: Int)>,
         abillityStone: Array<(key: String, value: Int)>,
         necklace: Accessory,
         earring1: Accessory,
         earring2: Accessory,
         ring1: Accessory,
         ring2: Accessory
    ) {
        self.targetEngraving = targetEngraving
        self.equipEngraving = equipEngraving
        self.abillityStone = abillityStone
        self.necklace = necklace
        self.earring1 = earring1
        self.earring2 = earring2
        self.ring1 = ring1
        self.ring2 = ring2
    }
    
    static func importPreviousData() -> Calculator {
        let targetEngraving: Array<(key: String, value: Int)> = [ // TE: Target Engraving,  V: Value
            (key: UserDefaults.standard.string(forKey: "TE1") ?? "", value: UserDefaults.standard.integer(forKey: "TEV1")),
            (key: UserDefaults.standard.string(forKey: "TE2") ?? "", value: UserDefaults.standard.integer(forKey: "TEV2")),
            (key: UserDefaults.standard.string(forKey: "TE3") ?? "", value: UserDefaults.standard.integer(forKey: "TEV3")),
            (key: UserDefaults.standard.string(forKey: "TE4") ?? "", value: UserDefaults.standard.integer(forKey: "TEV4")),
            (key: UserDefaults.standard.string(forKey: "TE5") ?? "", value: UserDefaults.standard.integer(forKey: "TEV5")),
            (key: UserDefaults.standard.string(forKey: "TE6") ?? "", value: UserDefaults.standard.integer(forKey: "TEV6")),
            (key: UserDefaults.standard.string(forKey: "TE7") ?? "", value: UserDefaults.standard.integer(forKey: "TEV7")),
        ]
            
        let equipEngraving: Array<(key: String, value: Int)> = [ // EE: Equip Engraving
            (key: UserDefaults.standard.string(forKey: "EE1") ?? "", value: UserDefaults.standard.integer(forKey: "EEV1")),
            (key: UserDefaults.standard.string(forKey: "EE2") ?? "", value: UserDefaults.standard.integer(forKey: "EEV2")),
        ]
        
        let abillityStone: Array<(key: String, value: Int)> = [ // AS: Abillity Stone,   P: Penalty
            (key: UserDefaults.standard.string(forKey: "AS1") ?? "", value: UserDefaults.standard.integer(forKey: "ASV1")),
            (key: UserDefaults.standard.string(forKey: "AS2") ?? "", value: UserDefaults.standard.integer(forKey: "ASV2")),
            (key: UserDefaults.standard.string(forKey: "ASP1") ?? "", value: UserDefaults.standard.integer(forKey: "ASPV1")),
        ]
        
        let data = Calculator(targetEngraving: targetEngraving,
                              equipEngraving: equipEngraving,
                              abillityStone: abillityStone,
                              necklace: Accessory.necklace(),
                              earring1: Accessory.earring1(),
                              earring2: Accessory.earring2(),
                              ring1: Accessory.ring1(),
                              ring2: Accessory.ring2()
        )
        
        return data
    }
}

struct Accessory {
    var code: String
    var usingAccessory: Bool
    var engraving: Array<(key: String, value: Int)> = []
    var quality: Int
    var stats1: String
    var stats2: String
    
    static func necklace() -> Accessory {
        let necklace: Array<(key: String, value: Int)> = [ // N: Necklace,  Q: Quality, SO: Stats One,  ST: Stats Two
            (key: UserDefaults.standard.string(forKey: "N1") ?? "", value: UserDefaults.standard.integer(forKey: "NV1")),
            (key: UserDefaults.standard.string(forKey: "N2") ?? "", value: UserDefaults.standard.integer(forKey: "NV2")),
            (key: UserDefaults.standard.string(forKey: "NP1") ?? "", value: UserDefaults.standard.integer(forKey: "NPV1")),
        ]
        
        let quality = UserDefaults.standard.integer(forKey: "NQ1")
        let stats1 = UserDefaults.standard.string(forKey: "NSO1") ?? ""
        let stats2 = UserDefaults.standard.string(forKey: "NST2") ?? ""
        let usingAccessory = UserDefaults.standard.bool(forKey: "NU")
        
        let accessory = Accessory(code: "200010-1", usingAccessory: usingAccessory, engraving: necklace, quality: quality, stats1: stats1, stats2: stats2)
        return accessory
    }
    
    static func earring1() -> Accessory {
        let earring1: Array<(key: String, value: Int)> = [ // EO: Earring One
            (key: UserDefaults.standard.string(forKey: "EO1") ?? "", value: UserDefaults.standard.integer(forKey: "EO1")),
            (key: UserDefaults.standard.string(forKey: "EO2") ?? "", value: UserDefaults.standard.integer(forKey: "EO2")),
            (key: UserDefaults.standard.string(forKey: "EOP1") ?? "", value: UserDefaults.standard.integer(forKey: "EOPV1")),
        ]
        
        let quality = UserDefaults.standard.integer(forKey: "EOQ1")
        let stats1 = UserDefaults.standard.string(forKey: "EOSO1") ?? ""
        let stats2 = UserDefaults.standard.string(forKey: "EOST2") ?? ""
        let usingAccessory = UserDefaults.standard.bool(forKey: "EOU")
        
        let accessory = Accessory(code: "200020-1", usingAccessory: usingAccessory, engraving: earring1, quality: quality, stats1: stats1, stats2: stats2)
        return accessory

    }
    
    static func earring2() -> Accessory {
        let earring2: Array<(key: String, value: Int)> = [ // ET: Earring Two
            (key: UserDefaults.standard.string(forKey: "ET1") ?? "", value: UserDefaults.standard.integer(forKey: "ETV1")),
            (key: UserDefaults.standard.string(forKey: "ET2") ?? "", value: UserDefaults.standard.integer(forKey: "ETV2")),
            (key: UserDefaults.standard.string(forKey: "ETP1") ?? "", value: UserDefaults.standard.integer(forKey: "ETPV1")),
        ]
        
        let quality = UserDefaults.standard.integer(forKey: "ETQ1")
        let stats1 = UserDefaults.standard.string(forKey: "ETSO1") ?? ""
        let stats2 = UserDefaults.standard.string(forKey: "ETST2") ?? ""
        let usingAccessory = UserDefaults.standard.bool(forKey: "ETU")

        let accessory = Accessory(code: "200020-2", usingAccessory: usingAccessory, engraving: earring2, quality: quality, stats1: stats1, stats2: stats2)
        return accessory
    }
    
    static func ring1() -> Accessory {
        let ring1: Array<(key: String, value: Int)> = [ // RO: Ring One
            (key: UserDefaults.standard.string(forKey: "RO1") ?? "", value: UserDefaults.standard.integer(forKey: "ROV1")),
            (key: UserDefaults.standard.string(forKey: "RO2") ?? "", value: UserDefaults.standard.integer(forKey: "ROV2")),
            (key: UserDefaults.standard.string(forKey: "ROP1") ?? "", value: UserDefaults.standard.integer(forKey: "ROPV1")),
        ]
        
        let quality = UserDefaults.standard.integer(forKey: "ROQ1")
        let stats1 = UserDefaults.standard.string(forKey: "ROSO1") ?? ""
        let stats2 = UserDefaults.standard.string(forKey: "ROST2") ?? ""
        let usingAccessory = UserDefaults.standard.bool(forKey: "ROU")

        let accessory = Accessory(code: "200030-1", usingAccessory: usingAccessory, engraving: ring1, quality: quality, stats1: stats1, stats2: stats2)
        return accessory
    }
    
    static func ring2() -> Accessory {
        let ring2: Array<(key: String, value: Int)> = [ // RT: Ring Two
            (key: UserDefaults.standard.string(forKey: "RT1") ?? "", value: UserDefaults.standard.integer(forKey: "RTV1")),
            (key: UserDefaults.standard.string(forKey: "RT2") ?? "", value: UserDefaults.standard.integer(forKey: "RTV2")),
            (key: UserDefaults.standard.string(forKey: "RTP1") ?? "", value: UserDefaults.standard.integer(forKey: "RTPV1")),
        ]
        
        let quality = UserDefaults.standard.integer(forKey: "RTQ1")
        let stats1 = UserDefaults.standard.string(forKey: "RTSO1") ?? ""
        let stats2 = UserDefaults.standard.string(forKey: "RTST2") ?? ""
        let usingAccessory = UserDefaults.standard.bool(forKey: "RTU")

        let accessory = Accessory(code: "200030-2", usingAccessory: usingAccessory, engraving: ring2, quality: quality, stats1: stats1, stats2: stats2)
        return accessory
    }
}
