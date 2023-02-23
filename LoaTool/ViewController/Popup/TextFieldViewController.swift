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
    @IBOutlet var pickerView: UIPickerView!
    
    weak var coordinator: AppCoordinator?
    var delegate: TextFieldDelegate?
    var text: String = ""
    var keyboardType = UIKeyboardType.default
    
    var allowPickerView: Bool = false
    var usingFilter: Bool = true
    var data: [String] = []
    var temp: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTextField()
        
        if data.count != 0 && allowPickerView {
            setupPickerView()
        }
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
        
        if allowPickerView {
            textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        temp = textField.text ?? ""
        
        pickerView.reloadAllComponents()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        completeAction(completeButton)
        return true
    }
}

extension TextFieldViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let data = self.data
        let filter = data.filter({ engraving in
            return engraving.contains("-") || engraving.contains(temp)
        })

        return usingFilter ? filter.count : data.count
    }
        
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        
        let data = self.data
        let filter = data.filter({ engraving in
            return engraving.contains("-") || engraving.contains(temp)
        })
        
        let text = usingFilter ? filter.sorted(by: { $0 < $1 })[safe: row] ?? "" : data[safe: row]
        
        label.text = text == "-" ? "" : text

        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let data = self.data
        let filter = data.filter({ engraving in
            return engraving.contains("-") || engraving.contains(temp)
        })

        let text = usingFilter ? filter.sorted(by: { $0 < $1 })[safe: row] ?? "" : data[safe: row]

        textField.text = text == "-" ? "" : text
    }
}
