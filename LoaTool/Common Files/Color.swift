//
//  Color.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//

import UIKit

extension UIColor {
    enum custom {
        /*
        static let blue: UIColor = UIColor(displayP3Red: 15/255, green: 15/255, blue: 200/255, alpha: 1)
        static let red: UIColor = UIColor(displayP3Red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        static let green: UIColor = UIColor(hex: 0x006400, alpha: 1)
        static let yellow: UIColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
         */
        
        static let itemGrade1: UIColor = UIColor(named: "Item Grade 1 Color")!
        static let itemGrade2: UIColor = UIColor(named: "Item Grade 2 Color")!
        static let itemGrade3: UIColor = UIColor(named: "Item Grade 3 Color")!
        static let itemGrade4: UIColor = UIColor(named: "Item Grade 4 Color")!
        static let itemGrade5: UIColor = UIColor(named: "Item Grade 5 Color")!
        static let itemGrade6: UIColor = UIColor(named: "Item Grade 6 Color")!
        static let itemGrade7: UIColor = UIColor(named: "Item Grade 7 Color")!

        static let qualityOrange: UIColor = UIColor(named: "Quality Orange")!
        static let qualityPurple: UIColor = UIColor(named: "Quality Purple")!
        static let qualityBlue: UIColor = UIColor(named: "Quality Blue")!
        static let qualityGreen: UIColor = UIColor(named: "Quality Green")!
        static let qualityYellow: UIColor = UIColor(named: "Quality Yellow")!
        static let qualityRed: UIColor = UIColor(named: "Quality Red")!
        static let qualityBackground: UIColor = UIColor(named: "Quality Background")!

        static let textBlue: UIColor = UIColor(named: "Text Blue")!
        static let secondaryTextBlue: UIColor = UIColor(named: "Secondary Text Blue")!

    }
    
    convenience init(hex: Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension Int {
    func getColor() -> UIColor {
        var color: UIColor
        
        switch self {
        case 1:
            color = .custom.itemGrade1
        case 2:
            color = .custom.itemGrade2
        case 3:
            color = .custom.itemGrade3
        case 4:
            color = .custom.itemGrade4
        case 5:
            color = .custom.itemGrade5
        case 6:
            color = .custom.itemGrade6
        case 7:
            color = .custom.itemGrade7
        default:
            color = .label
        }
        

        return color
    }
}

extension String {
    func getColor() -> UIColor {
        var color: UIColor
        
        switch self {
        case "일반":
            color = .white
        case "고급":
            color = .custom.itemGrade1
        case "희귀":
            color = .custom.itemGrade2
        case "영웅":
            color = .custom.itemGrade3
        case "전설":
            color = .custom.itemGrade4
        case "유물":
            color = .custom.itemGrade5
        case "고대":
            color = .custom.itemGrade6
        case "에스더":
            color = .custom.itemGrade7
        default:
            color = .label
        }
        

        return color
    }
}
