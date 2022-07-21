//
//  Toast.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/09/07.
//

import UIKit

class Toast {
    
    var image: UIImage? = nil
    var title: String? = nil
    var description: String? = nil
    
    var backgroundColor: UIColor = .systemBackground
    var tintColor: UIColor = .label
    
    init(image: UIImage?, title: String?, description: String?) {
        self.image = image
        self.title = title
        self.description = description
    }
    
    fileprivate func setupView() -> UIView {
        let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first { $0.isKeyWindow }

        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = backgroundColor
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.15
        
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5
        
        let imageView = UIImageView()
        imageView.tintColor = .systemRed
        imageView.image = image
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        view.addSubview(imageView)
        
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.textColor = tintColor
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = tintColor
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        stackView.addArrangedSubview(descriptionLabel)
        
        window?.addSubview(view)

        [view, imageView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: window!.topAnchor, constant: -(60 + 10)),
            view.widthAnchor.constraint(equalTo: window!.widthAnchor, constant: -20),
            view.trailingAnchor.constraint(equalTo: window!.trailingAnchor, constant: -10),
            view.heightAnchor.constraint(equalToConstant: 60),

            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 36),
            imageView.heightAnchor.constraint(equalToConstant: 36),
            
            stackView.topAnchor.constraint(equalTo: imageView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
        
        return view
    }
    
    func present() {
        let view = setupView()
        
        let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first { $0.isKeyWindow }
        let inset = window?.safeAreaInsets.top ?? 0
        let translationY: CGFloat = inset + 60 + 10 + 10
        
        UIView.animate(withDuration: 0.2, animations: {
            view.transform  = CGAffineTransform(translationX: 0, y: translationY)
            view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 2, options: .allowAnimatedContent, animations: {
                view.transform  = CGAffineTransform(translationX: 0, y: -translationY)
            }, completion: { _ in
                view.removeFromSuperview()
            })
        })
    }
}
