//
//  Lostark.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/19.
//

import UIKit

class Lostark {
    static let shared = Lostark()

    let grade4: [Int: Int] = [
        0: 1340,
        1: 1345,
        2: 1350,
        3: 1355,
        4: 1360,
        5: 1365,
        6: 1370,
        7: 1375,
        8: 1380,
        9: 1385,
        10: 1390,
        11: 1395,
        12: 1400,
        13: 1405,
        14: 1410,
        15: 1415,
        16: 1430,
        17: 1445,
        18: 1460,
        19: 1475,
        20: 1490,
        21: 1505,
        22: 1520,
        23: 1535,
        24: 1550,
        25: 1575
    ]
    
    let grade5: [Int: Int] = [
        0: 1340,
        1: 1345,
        2: 1350,
        3: 1355,
        4: 1360,
        5: 1365,
        6: 1370,
        7: 1375,
        8: 1380,
        9: 1385,
        10: 1390,
        11: 1395,
        12: 1400,
        13: 1405,
        14: 1410,
        15: 1415,
        16: 1430,
        17: 1445,
        18: 1460,
        19: 1475,
        20: 1490,
        21: 1505,
        22: 1520,
        23: 1535,
        24: 1550,
        25: 1575
    ]
    
    let grade5plus: [Int: Int] = [
        0: 1390,
        1: 1400,
        2: 1410,
        3: 1420,
        4: 1430,
        5: 1440,
        6: 1450,
        7: 1460,
        8: 1470,
        9: 1480,
        10: 1490,
        11: 1500,
        12: 1510,
        13: 1520,
        14: 1530,
        15: 1540,
        16: 1550,
        17: 1560,
        18: 1570,
        19: 1580,
        20: 1590
    ]
    
    let grade6: [Int: Int] = [
        0: 1390,
        1: 1400,
        2: 1410,
        3: 1420,
        4: 1430,
        5: 1440,
        6: 1450,
        7: 1460,
        8: 1470,
        9: 1480,
        10: 1490,
        11: 1500,
        12: 1510,
        13: 1520,
        14: 1530,
        15: 1540,
        16: 1550,
        17: 1560,
        18: 1570,
        19: 1580,
        20: 1590,
        21: 1595,
        22: 1600,
        23: 1605,
        24: 1610,
        25: 1615
    ]

    let grade6plus: [Int: Int] = [
        0: 1525,
        1: 1530,
        2: 1535,
        3: 1540,
        4: 1545,
        5: 1550,
        6: 1555,
        7: 1560,
        8: 1565,
        9: 1570,
        10: 1575,
        11: 1580,
        12: 1585,
        13: 1590,
        14: 1595,
        15: 1600,
        16: 1605,
        17: 1610,
        18: 1615,
        19: 1620,
        20: 1625,
        21: 1630,
        22: 1635,
        23: 1640,
        24: 1645,
        25: 1650
    ]

    let grade7: [Int: Int] = [
        0: 1100,
        1: 1200,
        2: 1300,
        3: 1400,
        4: 1500,
        5: 1600,
        6: 1625,
        7: 1635,
        8: 1645
    ]

    let grade7plus: [Int: Int] = [
        0: 1100,
        1: 1200,
        2: 1300,
        3: 1400,
        4: 1500,
        5: 1600,
        6: 1650,
        7: 1665,
        8: 1680
    ]

    func weapon(_ data: Equip) -> String {
        let level = data.level
        let step = Int(data.title.components(separatedBy: " ").first?.replacingOccurrences(of: "+", with: "") ?? "") ?? 0
        
        switch data.grade {
        case 4:
            return grade4[step] == level ? "전설 +\(level)" : ""
        case 5:
            if grade5[step] == level {
                return "유물 +\(step)"
            } else if grade5plus[step] == level {
                return "유물 계승 +\(step)"
            } else {
                return ""
            }
        case 6:
            if grade6[step] == level {
                return "고대 +\(step)"
            } else if grade6plus[step] == level {
                return "고대 계승 +\(step)"
            } else {
                return ""
            }
        case 7:
            if grade7[step] == level {
                return "에스더 +\(step)"
            } else if grade7plus[step] == level {
                return "에스더 엘라 +\(step)"
            } else {
                return ""
            }
        default:
            return ""
        }
        
        
    }
}
