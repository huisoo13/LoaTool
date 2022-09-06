//
//  EditCharacterViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/14.
//

import UIKit

class EditCharacterViewController: UIViewController, Storyboarded {
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var textFieldStackView: UIStackView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var ticketView: UIStackView!
    
    @IBOutlet weak var switchButton: UISwitch!
    
    weak var coordinator: AppCoordinator?

    var isUpdated: Bool = false
    var data: Member?
    var selectTextFieldAtIndex: Int = 0
    
    let bonus = ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
    let limit = ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "X"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupData()
        setupGestureRecognizer()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setupView() {
        
        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor

        textFieldStackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray4.cgColor
            view.layer.cornerRadius = 6
            
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }
            textField.isUserInteractionEnabled = false
        }
        
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let iconView = view.subviews.first,
                  let stackView = view.subviews.last as? UIStackView else { return }
            
            iconView.layer.cornerRadius = 6
            iconView.layer.borderWidth = 0.5
            iconView.layer.borderColor = UIColor.systemGray4.cgColor

            stackView.arrangedSubviews.enumerated().forEach { j, view in
                guard let pickerView = view.subviews.last as? UIPickerView else { return }
                
                pickerView.delegate = self
                pickerView.dataSource = self
                
                pickerView.tag = (i * 10) + j
                
                pickerView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                pickerView.tintColor = .clear
                pickerView.showsLargeContentViewer = true
            }
        }
        
        ticketView.arrangedSubviews.enumerated().forEach { i, view in
            guard let iconView = view.subviews.first,
                  let stackView = view.subviews.last as? UIStackView else { return }
            
            iconView.layer.cornerRadius = 6
            iconView.layer.borderWidth = 0.5
            iconView.layer.borderColor = UIColor.systemGray4.cgColor

            stackView.arrangedSubviews.enumerated().forEach { j, view in
                guard let pickerView = view.subviews.last as? UIPickerView else { return }
                
                pickerView.delegate = self
                pickerView.dataSource = self
                
                pickerView.tag = 100 + (i * 10) + j
                
                pickerView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                pickerView.tintColor = .clear
                pickerView.showsLargeContentViewer = true
            }
        }
        
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

    }
    
    func setupData() {
        isUpdated = data != nil
        
        guard let data = data else {
            data = Member()
            data?.identifier = UUID().uuidString
            data?.category = 1
            
            let contents = [Content(identifier: UUID().uuidString,
                                    title: "가디언 토벌",
                                    icon: 6,
                                    value: 0,
                                    maxValue: 2,
                                    bonusValue: 0,
                                    minBonusValue: 0,
                                    originBonusValue: 0,
                                    weekday: [1, 2, 3, 4, 5, 6, 7]),
                            Content(identifier: UUID().uuidString,
                                    title: "카오스 던전",
                                    icon: 8,
                                    value: 0,
                                    maxValue: 2,
                                    bonusValue: 0,
                                    minBonusValue: 0,
                                    originBonusValue: 0,
                                    weekday: [1, 2, 3, 4, 5, 6, 7]),
                            Content(identifier: UUID().uuidString,
                                    title: "에포나 의뢰",
                                    icon: 0,
                                    value: 0,
                                    maxValue: 3,
                                    bonusValue: 0,
                                    minBonusValue: 0,
                                    originBonusValue: 0,
                                    weekday: [1, 2, 3, 4, 5, 6, 7])
            ]
            
            data?.contents.append(objectsIn: contents)
            
            return
        }

        jobImageView.image = data.job.getSymbol()
        textFieldStackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }

            switch i {
            case 0:
                textField.text = data.name
            case 1:
                textField.text = "\(data.level)"
            default:
                break
            }
        }
        
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let stackView = view.subviews.last as? UIStackView else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { j, view in
                guard let pickerView = view.subviews.last as? UIPickerView,
                let row = j == 0 ? data.contents[safe: i]?.bonusValue : data.contents[safe: i]?.minBonusValue else { return }

                pickerView.selectRow(row / 10, inComponent: 0, animated: false)
            }
        }
        
        ticketView.arrangedSubviews.enumerated().forEach { i, view in
            guard let stackView = view.subviews.last as? UIStackView else { return }
            
            stackView.arrangedSubviews.enumerated().forEach { j, view in
                guard let pickerView = view.subviews.last as? UIPickerView else { return }
                
                let row = i == 0 ? data.cube : data.boss
                pickerView.selectRow(row, inComponent: 0, animated: false)
            }
        }
        
        switchButton.isOn = RealmManager.shared.readAll(Todo.self).first?.gold.contains(data.identifier) ?? false
    }
    
    func setupGestureRecognizer() {
        jobView.addGestureRecognizer { _ in
            self.coordinator?.presentToJobPickerViewController(self, animated: true)
        }

        textFieldStackView.arrangedSubviews.enumerated().forEach { i, view in
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.selectTextFieldAtIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "이름", keyboardType: .default, animated: true)
                }
            case 1:
                view.addGestureRecognizer { _ in
                    self.selectTextFieldAtIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "레벨", keyboardType: .decimalPad, animated: true)
                }
            default:
                break
            }
        }
        
        switchButton.isUserInteractionEnabled = true
        switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        let isOn = sender.isOn
        if !self.isUpdated { return }
        
        guard let todo = RealmManager.shared.readAll(Todo.self).first,
              let data = self.data else { return }
        RealmManager.shared.update {
            if isOn {
                todo.gold.append(data.identifier)
            } else {
                guard let index = todo.gold.firstIndex(of: data.identifier) else { return }
                todo.gold.remove(at: index)
            }
        }
        
        print(todo.gold)
    }
}

extension EditCharacterViewController {
    fileprivate func setupNavigationBar() {
        setTitle("캐릭터 설정".localized, size: 20)
        
        let complete = UIBarButtonItem(title: isUpdated ? "삭제" : "추가", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = isUpdated ? .systemRed : .systemBlue

        addRightBarButtonItems([complete])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        if isUpdated {
            let alert = UIAlertController(title: "캐릭터 삭제", message: "해당 캐릭터를 삭제하여\n할 일 관리에서 제외합니다.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "삭제", style: .destructive) { _ in
                guard let data = self.data,
                      let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
                
                RealmManager.shared.update {
                    additional.forEach { content in
                        guard let index = content.included.firstIndex(of: data.identifier) else { return }
                        content.included.remove(at: index)
                        
                        guard let index = content.completed.firstIndex(of: data.identifier) else { return }
                        content.completed.remove(at: index)
                    }
                    
                    guard let gold = RealmManager.shared.readAll(Todo.self).first?.gold,
                          let index = gold.firstIndex(of: data.identifier) else { return }
                    gold.remove(at: index)
                }
                
                RealmManager.shared.delete(data)

                self.coordinator?.popViewController(animated: true)
            }
            
            let no = UIAlertAction(title: "취소", style: .cancel) { _ in }
            
            alert.addAction(no)
            alert.addAction(ok)
            
            self.present(alert, animated: true)
        } else {
            guard let data = self.data,
                    data.job != "", data.name != "" else {
                        Alert.message(self, title: "정보 부족", message: "설정한 직업과 이름을 확인해주세요", handler: nil)
                        return
                    }
            
            RealmManager.shared.update {
                let todo = RealmManager.shared.readAll(Todo.self).first
                todo?.member.append(data)
                
                if self.switchButton.isOn {
                    todo?.gold.append(data.identifier)
                }
            }
                        
            self.coordinator?.popViewController(animated: true)
        }
    }
}


extension EditCharacterViewController: JobPickerViewDelegate, TextFieldDelegate {
    func pickerView(_ symbol: UIImage, job: String, didSelectItemAt index: Int) {
        RealmManager.shared.update {
            self.data?.job = job
            self.jobImageView.image = symbol
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text,
              let textField = textFieldStackView.arrangedSubviews[safe: selectTextFieldAtIndex]?.subviews[safe: 1] as? UITextField else { return }

        textField.text = text
        
        RealmManager.shared.update {
            switch self.selectTextFieldAtIndex {
            case 0:
                self.data?.name = text
            case 1:
                self.data?.level = Double(text) ?? 0.0
            default:
                break
            }
        }
    }
}

extension EditCharacterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag < 100 {
            return pickerView.tag % 10 == 0 ? bonus.count : limit.count
        } else {
            return 100
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        30
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()

        if pickerView.tag < 100 {
            let titles = pickerView.tag % 10 == 0 ? bonus : limit
            label.text = titles[row]
            label.textColor = .custom.textBlue
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .center
            
            label.transform = CGAffineTransform(rotationAngle: .pi / 2)
        } else {
            label.text = "\(row)"
            label.textColor = .custom.textBlue
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .center
            
            label.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        
        RealmManager.shared.update {
            if pickerView.tag < 100 {
                guard let content = self.data?.contents[safe: pickerView.tag / 10] else { return }
                
                if pickerView.tag % 10 == 0 {
                    content.bonusValue = row * 10
                    content.originBonusValue = row * 10
                }
                
                if pickerView.tag % 10 == 1 { content.minBonusValue = row * 10 }
            } else {                
                switch pickerView.tag {
                case 100:
                    self.data?.cube = row
                case 110:
                    self.data?.boss = row
                default:
                    break
                }
            }
        }
    }
}
