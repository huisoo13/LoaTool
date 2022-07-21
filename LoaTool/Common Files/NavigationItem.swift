//
//  NavigationItem.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/08.
//

import UIKit

extension UIViewController {
    
    func setTitle(_ text: String, size: CGFloat = 18, backButtonHandler: (()->())? = nil) {
        // 타이틀 설정
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.titleView = UIView()
        
        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .systemFont(ofSize: size, weight: .medium)
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.contentMode = .scaleAspectFit
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 5
        
        let numberOfController = self.navigationController?.viewControllers.count ?? 0
        if numberOfController > 1 {
            stackView.addArrangedSubview(imageView)
            stackView.addGestureRecognizer { _ in
                backButtonHandler?()
                self.navigationController?.popViewController(animated: true)
            }
        }

        stackView.addArrangedSubview(label)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: stackView)
                
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func addRightBarButtonItems(_ items: [UIBarButtonItem]) {
        self.navigationItem.rightBarButtonItems = items
    }
    
    func addRightBarButtonItemMenu(_ menu: UIMenu) {
        self.navigationItem.rightBarButtonItem?.menu = menu
    }

    func removeRightBarButtonItem() {
        self.navigationItem.rightBarButtonItems = []
    }
    
}
