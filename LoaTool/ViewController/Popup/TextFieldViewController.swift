//
//  TextFieldViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/07.
//

import UIKit

protocol TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField)
}

class TextFieldViewController: UIViewController, Storyboarded {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var coordinator: AppCoordinator?
    var delegate: TextFieldDelegate?
    var text: String = ""
    var keyboardType = UIKeyboardType.default

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setupView() {
        titleLabel.text = text
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        delegate?.textFieldShouldReturn(textField)
        coordinator?.dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        coordinator?.dismiss(animated: true)
    }
}

extension TextFieldViewController: UITextFieldDelegate {
    func setupTextField() {
        textField.delegate = self
        textField.keyboardType = keyboardType
        
        textField.returnKeyType = .done
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        completeAction(completeButton)
        return true
    }
}
