//
//  CalculatorACcessoryViewController.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/13.
//

import UIKit

class CalculatorAccessoryViewController: UIViewController, Storyboarded {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var stackView: UIStackView!
    
    weak var coordinator: AppCoordinator?

    var data: Accessory?
    var selectedRow: Int = 0
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()
        setupGestureRecognizer()
    }
    
    func setupView() {
        guard let data = self.data else { return }
        
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchButton.isOn = data.usingAccessory
        
        stackView.arrangedSubviews.enumerated().forEach { j, view in
            guard let stackView = view as? UIStackView else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let label = view.subviews.first as? UILabel,
                      let textField = view.subviews.last as? UITextField else { return }
                
                switch i {
                case 0:
                    label.text = j != 2 ? "• 각인" : "• 감소 효과"
                    textField.text = data.engraving[j].key
                case 1:
                    textField.text = data.engraving[j].value == 0 ? "" : "+\(data.engraving[j].value)"
                default:
                    break
                }
                
                textField.textColor = j != 2 ? .label : .systemRed
            }
        }
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach { j, view in
            guard let stackView = view as? UIStackView else { return }
            
            stackView.arrangedSubviews.enumerated().forEach({ i, view in
                switch i {
                case 0:
                    view.addGestureRecognizer { _ in
                        self.selectedRow = j
                        self.selectedIndex = i

                        if j != 2 {
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
                        self.selectedRow = j
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
        
        switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        guard let code = self.data?.code else { return }
        
        let key: String
        
        switch code {
        case "200010-1":
            key = "NU"
        case "200020-1":
            key = "EOU"
        case "200020-2":
            key = "ETU"
        case "200030-1":
            key = "ROU"
        case "200030-2":
            key = "RTU"
        default:
            return
        }

        UserDefaults.standard.set(sender.isOn, forKey: key)

    }
}

extension CalculatorAccessoryViewController {
    fileprivate func setupNavigationBar() {
        setTitle("보유 악세서리 설정".localized, size: 20)
    }
}

extension CalculatorAccessoryViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        stackView.arrangedSubviews.enumerated().forEach { j, view in
            guard let stackView = view as? UIStackView else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                if selectedRow == j && selectedIndex == i {
                    guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                          let textField = view.subviews.last as? UITextField,
                          let code = self.data?.code else { return }
                    
                    switch i {
                    case 0:
                        textField.text = text
                        
                        let key: String
                        
                        switch code {
                        case "200010-1":
                            key = j != 2 ? "N\(j + 1)" : "NP1"
                        case "200020-1":
                            key = j != 2 ? "EO\(j + 1)" : "EOP1"
                        case "200020-2":
                            key = j != 2 ? "ET\(j + 1)" : "ETP1"
                        case "200030-1":
                            key = j != 2 ? "RO\(j + 1)" : "ROP1"
                        case "200030-2":
                            key = j != 2 ? "RT\(j + 1)" : "RTP1"
                        default:
                            return
                        }
                        
                        UserDefaults.standard.set(text, forKey: key)
                    case 1:
                        textField.text = text == "" ? "" : "+" + text
                        
                        let key: String
                        
                        switch code {
                        case "200010-1":
                            key = j != 2 ? "NV\(j + 1)" : "NPV1"
                        case "200020-1":
                            key = j != 2 ? "EOV\(j + 1)" : "EOPV1"
                        case "200020-2":
                            key = j != 2 ? "ETV\(j + 1)" : "ETPV1"
                        case "200030-1":
                            key = j != 2 ? "ROV\(j + 1)" : "ROPV1"
                        case "200030-2":
                            key = j != 2 ? "RTV\(j + 1)" : "RTPV1"
                        default:
                            return
                        }
                        
                        UserDefaults.standard.set(Int(text) ?? 0, forKey: key)
                    default:
                        break
                    }
                }
            }
        }
    }
}
