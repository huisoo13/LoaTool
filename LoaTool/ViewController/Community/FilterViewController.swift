//
//  FilterViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/29.
//

import UIKit

class FilterViewController: UIViewController, Storyboarded {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    
    @IBOutlet var switchs: [UISwitch]!
    
    weak var coordinator: AppCoordinator?
    
    var filterOptions = CommunityViewController.options
    
    var type: Int = CommunityViewController.options.type
    var isMine: Bool = CommunityViewController.options.isMine
    var isLiked: Bool = CommunityViewController.options.isLiked
    var isMarked: Bool = CommunityViewController.options.isMarked

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setupView() {
        textField.becomeFirstResponder()
        textField.text = filterOptions.text
        
        textFieldView.layer.borderWidth = 0.5
        textFieldView.layer.borderColor = UIColor.systemGray4.cgColor
        textFieldView.layer.cornerRadius = 6
                
        switchs.enumerated().forEach { i, item in
            item.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            item.tag = i

            switch i {
            case 0:
                item.isOn = self.filterOptions.isMine
            case 1:
                item.isOn = self.filterOptions.isLiked
            case 2:
                item.isOn = self.filterOptions.isMarked
            default:
                break
            }
        }
        
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 12)
        
        var configure = button.configuration
        configure?.attributedTitle = AttributedString(type == 0 ? "내용" : "작성자", attributes: container)
        
        button.configuration = configure
        
        setupButtonMenu()
        setupGestureRecognizer()
    }
    
    func setupButtonMenu() {
        let text = UIAction(title: "내용", subtitle: nil, image: nil, identifier: nil) { action in
            let title = action.title
            
            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 12)

            var configure = self.button.configuration
            configure?.attributedTitle = AttributedString(title, attributes: container)
            
            self.button.configuration = configure
            self.type = 0
        }
        
        let name = UIAction(title: "작성자", subtitle: nil, image: nil, identifier: nil) { action in
            let title = action.title

            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 12)

            var configure = self.button.configuration
            configure?.attributedTitle = AttributedString(title, attributes: container)
            
            self.button.configuration = configure
            self.type = 1
        }

        let menu = UIMenu(title: "분류", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [text, name])
        
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    func setupGestureRecognizer() {
        switchs.enumerated().forEach { i, switchButton in
            switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        }
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            isMine = sender.isOn
        case 1:
            isLiked = sender.isOn
        case 2:
            isMarked = sender.isOn
        default:
            break
        }
    }
}

extension FilterViewController {
    fileprivate func setupNavigationBar() {
        setTitle("필터 설정".localized, size: 20)
        
        coordinator?.backgroundColor = .systemBackground
        
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = .systemBlue

        addRightBarButtonItems([complete])
    }
        
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        CommunityViewController.reloadToData = true
        
        guard let text = textField.text else { return }
        filterOptions.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        filterOptions.isMine = self.isMine
        filterOptions.isLiked = self.isLiked
        filterOptions.isMarked = self.isMarked
        filterOptions.type = self.type
        
        CommunityViewController.options = filterOptions
                
        coordinator?.popViewController(animated: true)
    }
}

extension FilterViewController: UITextFieldDelegate {
    func setupTextField() {
        textField.delegate = self
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    @objc func editingChanged(_ sender: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedBarButtonItem(UIBarButtonItem())
        
        return true
    }
}
