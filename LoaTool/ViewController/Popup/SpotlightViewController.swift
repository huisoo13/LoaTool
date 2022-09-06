//
//  SpotlightViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/07/29.
//

// 현재 사용하지 않음

import UIKit

class SpotlightViewController: UIViewController, Storyboarded {
    weak var coordinator: AppCoordinator?

    var rect: CGRect?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setupView() {
        guard let rect = rect else { return }
        
        let shadowRect = UIScreen.main.bounds
        let lightRect = rect
        
        let shadowPath = UIBezierPath(rect: shadowRect)
        let lightPath = UIBezierPath(roundedRect: lightRect, cornerRadius: lightRect.height / 2)
        
        shadowPath.append(lightPath)
        shadowPath.usesEvenOddFillRule = true

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = shadowPath.cgPath
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        // shapeLayer.opacity = 0.4
        view.layer.addSublayer(shapeLayer)

        
        guard let text = text else { return }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.textAlignment = rect.midX == UIScreen.main.bounds.midX ? .center : (rect.midX > UIScreen.main.bounds.midX ? .right : .left)
        label.numberOfLines = 0
        
        label.frame = CGRect(center: CGPoint(x: UIScreen.main.bounds.width / 2, y: rect.maxY + 32), size: CGSize(width: UIScreen.main.bounds.width - 32, height: 50))
        
        view.addSubview(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        coordinator?.dismiss(animated: true)
    }
}
