//
//  CalculatorTargetTableViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit

class CalculatorTargetTableViewCell: UITableViewCell {
    @IBOutlet var stackView: UIStackView!
    
    weak var coordinator: AppCoordinator?
    
    var row: Int = 0
    var data: (key: String, value: Int)? {
        didSet {
            guard let data = data else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let textField = view.subviews.last as? UITextField else { return }

                switch i {
                case 0:
                    textField.text = data.key
                case 1:
                    textField.text = data.value == 0 ? "" : "Lv. \(data.value)"
                default:
                    break
                    
                }
            }
        }
    }

    var selectedIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none

        setupGestureRecognizer()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach({ i, view in
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "각인 선택", allowPickerView: true, data: String.engraving(), usingFilter: true, keyboardType: .default, animated: true)
                }
            case 1:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "각인 레벨", allowPickerView: true, data: ["0", "1", "2", "3"], usingFilter: false, keyboardType: .numberPad, animated: true)
                }
            default:
                break
            }
        })
    }
}

extension CalculatorTargetTableViewCell: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            if selectedIndex == i {
                guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let textField = view.subviews.last as? UITextField else { return }
                
                switch i {
                case 0:
                    textField.text = text
                    UserDefaults.standard.set(text, forKey: "TE\(row + 1)")
                case 1:
                    textField.text = text == "" ? "" : "Lv. " + text
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "TEV\(row + 1)")
                default:
                    break
                }
            }
        }
    }
}
