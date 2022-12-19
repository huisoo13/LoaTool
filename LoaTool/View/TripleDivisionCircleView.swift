//
//  TripleDivisionCircleView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/19.
//

import UIKit

class TripleDivisionCircleView: UIView {

    @IBInspectable var lineWidth: CGFloat = 3
    
    var value: Int? {
        didSet {
            guard let value = value else {
                return
            }

            setProgress(self.bounds, value: value)
        }
    }
    
    var text: String? = nil
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        
        bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX - ((lineWidth - 1) / 2), startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        bezierPath.lineWidth = 1
        UIColor.systemGray4.set()
        bezierPath.stroke()
        
        setProgress(rect)
    }
    
    func setProgress(_ rect: CGRect, value: Int? = nil) {
        guard let value = value else { return }
        
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        var numberOfArc: Int = 0
        var startAngle = -(CGFloat.pi / 2) + 0.2

        while numberOfArc < value {
            numberOfArc += 1
            
            let bezierPath = UIBezierPath()
                   
            let endAngle = startAngle + (.pi * 2 / 3 - 0.2) - 0.2
            bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX - ((lineWidth - 1) / 2), startAngle: startAngle, endAngle: endAngle, clockwise: true)
            startAngle = endAngle + 0.4
            
            let shapeLayer = CAShapeLayer()
            
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.lineCap = .square
            
            let color: UIColor = .custom.qualityBlue

            shapeLayer.strokeColor = color.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = lineWidth
            
            self.layer.addSublayer(shapeLayer)
        }
        
        
        let label = UILabel()
        label.text = String(value)
        label.textColor = .label
        label.font = .systemFont(ofSize: 8, weight: .light)
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
