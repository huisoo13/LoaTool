//
//  CalculatorAccessoryTableViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit

class CalculatorAccessoryTableViewCell: UITableViewCell {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var button: UIButton!
    @IBOutlet var usingView: UIImageView!
    
    weak var coordinator: AppCoordinator?

    var accessory: Accessory? {
        didSet {
            guard let data = accessory else { return }
            
            usingView.isHidden = !data.usingAccessory
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                switch i {
                case 0:
                    guard let label = view.subviews.first as? UILabel else { return }
                    switch data.code {
                    case "200010-1":
                        label.text = "• 목걸이"
                    case "200020-1":
                        label.text = "• 귀걸이1"
                    case "200020-2":
                        label.text = "• 귀걸이2"
                    case "200030-1":
                        label.text = "• 반지1"
                    case "200030-2":
                        label.text = "• 반지2"
                    default:
                        break
                    }
                case 1:
                    guard let textField = view.subviews.last as? UITextField else { return }
                    textField.text = data.quality == 0 ? "" : "\(data.quality)"
                case 2:
                    guard let textField = view.subviews.last as? UITextField else { return }
                    textField.text = data.stats1
                case 3:
                    view.subviews.forEach { $0.isHidden = (data.code.components(separatedBy: "-").first ?? "") != "200010" }
                    
                    guard let textField = view.subviews.last as? UITextField else { return }
                    textField.text = data.stats2
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
        
        setupButton()
        setupGestureRecognizer()
    }
    
    func setupButton() {
        button.transform = CGAffineTransform(rotationAngle: .pi / 2)
        button.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        self.coordinator?.pushToCalculatorACcessoryViewController(accessory, animated: true)
    }

    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach({ i, view in
            switch i {
            case 1:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self,
                                                                       title: "품질",
                                                                       keyboardType: .numberPad,
                                                                       animated: true)
                }
            case 2:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self,
                                                                       title: "특성 선택",
                                                                       allowPickerView: true,
                                                                       data: ["-", "특화", "치명", "신속", "인내", "제압", "숙련"],
                                                                       usingFilter: false,
                                                                       keyboardType: .default,
                                                                       animated: true)
                }
            case 3:
                view.addGestureRecognizer { _ in
                    self.selectedIndex = i
                    self.coordinator?.presentToTextFieldViewController(self,
                                                                       title: "특성 선택",
                                                                       allowPickerView: true,
                                                                       data: ["-", "특화", "치명", "신속", "인내", "제압", "숙련"],
                                                                       usingFilter: false,
                                                                       keyboardType: .default,
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

extension CalculatorAccessoryTableViewCell: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            if selectedIndex == i {
                guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let textField = view.subviews.last as? UITextField else { return }
                textField.text = text
                
                guard let data = accessory else { return }
                switch (data.code, i) {
                case ("200010-1", 1):
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "NQ1")
                case ("200010-1", 2):
                    UserDefaults.standard.set(text, forKey: "NSO1")
                case ("200010-1", 3):
                    UserDefaults.standard.set(text, forKey: "NST2")
                case ("200020-1", 1):
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "EOQ1")
                case ("200020-1", 2):
                    UserDefaults.standard.set(text, forKey: "EOSO1")
                case ("200020-1", 3):
                    UserDefaults.standard.set(text, forKey: "EOST2")
                case ("200020-2", 1):
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "ETQ1")
                case ("200020-2", 2):
                    UserDefaults.standard.set(text, forKey: "ETSO1")
                case ("200020-2", 3):
                    UserDefaults.standard.set(text, forKey: "ETST2")
                case ("200030-1", 1):
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "ROQ1")
                case ("200030-1", 2):
                    UserDefaults.standard.set(text, forKey: "ROSO1")
                case ("200030-1", 3):
                    UserDefaults.standard.set(text, forKey: "ROST2")
                case ("200030-2", 1):
                    UserDefaults.standard.set(Int(text) ?? 0, forKey: "RTQ1")
                case ("200030-2", 2):
                    UserDefaults.standard.set(text, forKey: "RTSO1")
                case ("200030-2", 3):
                    UserDefaults.standard.set(text, forKey: "RTST2")
                default:
                    break
                }
            }
        }
    }
}
