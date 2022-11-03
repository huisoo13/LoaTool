//
//  Loading.swift
//  ActivityIndicatorViewSample
//
//  Created by AppDeveloper on 2020/07/24.
//  Copyright © 2020 Taijoo. All rights reserved.
//

import UIKit

enum IndicatorStyle {
    case horizontal
    case vertical
}

class IndicatorView {
    static let shared = IndicatorView()
    
    static var loadingView: UIView = UIView()
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    func indicator(_ view: UIView, title: String = "", style: IndicatorStyle) -> UIActivityIndicatorView {
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        loadingView.backgroundColor = .black.withAlphaComponent(0.5)
        loadingView.layer.cornerRadius = 8

        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicator.color = .systemGray

        loadingView.addSubview(indicator)
        loadingView.bringSubviewToFront(indicator)

        indicator.translatesAutoresizingMaskIntoConstraints = false

        if title != "" {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 5
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
            loadingView.addSubview(titleLabel)

            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            switch style {
            case .horizontal:
                indicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 10).isActive = true
                indicator.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: -10).isActive = true
                indicator.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 10).isActive = true
                indicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
                indicator.heightAnchor.constraint(equalToConstant: 30).isActive = true

                titleLabel.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 10).isActive = true
                titleLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: -10).isActive = true
                titleLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 5).isActive = true
                titleLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -15).isActive = true
            case .vertical:
                indicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 10).isActive = true
                indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true

                indicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
                indicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
                
                titleLabel.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 5).isActive = true
                titleLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: -10).isActive = true
                titleLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 15).isActive = true
                titleLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -15).isActive = true

            }

            
        } else {
            indicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 10).isActive = true
            indicator.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: -10).isActive = true
            indicator.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 10).isActive = true
            indicator.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -10).isActive = true

            indicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
            indicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        return indicator
    }
    
    static func showLoadingView(title: String = "데이터를 불러오는 중입니다.") {
        let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first { $0.isKeyWindow }

        IndicatorView.loadingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        IndicatorView.loadingView.backgroundColor = .black.withAlphaComponent(0.5)
        IndicatorView.loadingView.alpha = 0
        
        let indicatorView = IndicatorView.shared.indicator(IndicatorView.loadingView, title: title, style: .vertical)
        indicatorView.color = .white
        indicatorView.startAnimating()
        
        window?.addSubview(IndicatorView.loadingView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            IndicatorView.loadingView.alpha = 1
        }, completion: nil)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
            if IndicatorView.loadingView != UIView() {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    IndicatorView.loadingView.alpha = 0
                }, completion: { _ in
                    IndicatorView.loadingView.removeFromSuperview()
                    IndicatorView.loadingView = UIView()
                })
            }
        })
    }
    
    static func hideLoadingView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            IndicatorView.loadingView.alpha = 0
        }, completion: { _ in
            IndicatorView.loadingView.removeFromSuperview()
            IndicatorView.loadingView = UIView()
        })
    }
}
