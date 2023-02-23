//
//  CalculatorEquipmentTableViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit

class CalculatorEquipmentTableViewCell: UITableViewCell {

    @IBOutlet var stackView: UIStackView!
    
    weak var coordinator: AppCoordinator?
    
    var row: Int = 0
    var isAbillityStone: Bool = false
    var isPenalty: Bool = false
    var data: (key: String, value: Int)? {
        didSet {
            guard let data = data else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let textField = view.subviews.last as? UITextField else { return }

                switch i {
                case 0:
                    textField.text = data.key
                    
                    guard let label = view.subviews.first as? UILabel else { return }
                    label.text = !isPenalty ? "• 각인" : "• 감소 효과"
                case 1:
                    textField.text = data.value == 0 ? "" : "+\(data.value)"
                default:
                    break
                }
                
                textField.textColor = !isPenalty ? .label : .systemRed
            }
        }
    }
    
    var selectedIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        setupGestureRecognizer()

    }

    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach({ i, view in
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    
                    if !self.isPenalty {
                        self.coordinator?.presentToTextFieldViewController(self,
                                                                           title: "각인 선택",
                                                                           allowPickerView: true,
                                                                           data: String.engraving(),
                                                                           usingFilter: true,
                                                                           keyboardType: .default,
                                                                           animated: true)
                    } else {
                        self.coordinator?.presentToTextFieldViewController(self,
                                                                           title: "감소 효과 선택",
                                                                           allowPickerView: true,
                                                                           data: String.engrave(true),
                                                                           usingFilter: false,
                                                                           keyboardType: .default,
                                                                           animated: true)
                    }
                }
            case 1:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self,
                                                                       title: "활성도",
                                                                       keyboardType: .numberPad,
                                                                       animated: true)
                }
            default:
                break
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CalculatorEquipmentTableViewCell: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            if selectedIndex == i {
                guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let textField = view.subviews.last as? UITextField else { return }
                
                switch (i, isAbillityStone, isPenalty) {
                case (0, false, false):
                    textField.text = text
                    UserDefaults.standard.set(text, forKey: "EE\(row + 1)")
                case (1, false, false):
                    textField.text = text == "" ? "" : "+" + text
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "EEV\(row + 1)")
                case (0, true, false):
                    textField.text = text
                    UserDefaults.standard.set(text, forKey: "AS\(row + 1)")
                case (1, true, false):
                    textField.text = text == "" ? "" : "+" + text
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "ASV\(row + 1)")
                case (0, true, true):
                    textField.text = text
                    UserDefaults.standard.set(text, forKey: "ASP1")
                case (1, true, true):
                    textField.text = text == "" ? "" : "+" + text
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "ASPV1")
                    
                default:
                    break
                }
            }
        }
    }
}
