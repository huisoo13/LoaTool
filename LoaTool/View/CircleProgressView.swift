//
//  CircleProgressView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/11/12.
//

import UIKit

class CircleProgressView: UIView {
    
    @IBInspectable var lineWidth: CGFloat = 3
    
    var value: Double? {
        didSet {
            guard let _ = value else {
                return
            }

            setProgress(self.bounds)
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
        
        guard let text = text else { return }
        setProgress(text)
    }
    
    func setProgress(_ rect: CGRect) {
        guard let value = self.value else {
            return
        }

        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX - ((lineWidth - 1) / 2), startAngle: -.pi / 2, endAngle: ((.pi * 2) * value) - (.pi / 2), clockwise: true)

        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineCap = .round
        
        let color: UIColor = value >= 1 ? .custom.qualityOrange :
        (value >= 0.9 ? .custom.qualityPurple :
            (value >= 0.7 ? .custom.qualityBlue :
                (value >= 0.3 ? .custom.qualityGreen :
                    (value >= 0.1 ? .custom.qualityYellow : .custom.qualityRed))))

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(shapeLayer)
        
        let label = UILabel()
        label.text = String(Int(value * 100))
        label.textColor = .label
        label.font = .systemFont(ofSize: 8, weight: .light)
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func setProgress(_ value: String) {
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let label = UILabel()
        label.text = value
        label.textColor = .label
        label.font = .systemFont(ofSize: 8, weight: .light)
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
