//
//  ShapeView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/09/17.
//

import UIKit

class ShapeView: UIView {

    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: width * 0.0, y: height * 0.50))
        bezierPath.addCurve(to: CGPoint(x: width * 0.50, y: height * 0.0), controlPoint1: CGPoint(x: width * 0.0, y: height * 0.15), controlPoint2: CGPoint(x: width * 0.15, y: height * 0.0))
        bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.50), controlPoint1: CGPoint(x: width * 0.85, y: height * 0.0), controlPoint2: CGPoint(x: width * 1, y: height * 0.15))
        bezierPath.addCurve(to: CGPoint(x: width * 0.50, y: height * 1), controlPoint1: CGPoint(x: width * 1, y: height * 0.85), controlPoint2: CGPoint(x: width * 0.85, y: height * 1))
        bezierPath.addCurve(to: CGPoint(x: width * 0.0, y: height * 0.50), controlPoint1: CGPoint(x: width * 0.15, y: height * 1), controlPoint2: CGPoint(x: width * 0.0, y: height * 0.85))
        
        
        UIColor.white.setFill()
        bezierPath.fill()

    }
}
