//
//  EditContentViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/15.
//

import UIKit

class EditContentViewController: UIViewController, Storyboarded {
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var advancedView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    var data: AdditionalContent?
    var selectTextFieldAtIndex: Int = 0
    var isUpdated: Bool = false
    var type: Int = 0       // 0: 원정대   1: 캐릭터
    var category: Int = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupData()
        setupGestureRecognizer()
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupView() {
        iconView.layer.cornerRadius = 6
        iconView.layer.borderWidth = 0.5
        iconView.layer.borderColor = UIColor.systemGray4.cgColor

        stackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray4.cgColor
            view.layer.cornerRadius = 6
            
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }
            textField.isUserInteractionEnabled = false
        }
        
        switchButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        segmentedControl.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    func setupData() {
        isUpdated = data != nil
        
        guard let data = data else {
            data = AdditionalContent()
            data?.identifier = UUID().uuidString
            data?.weekday.append(objectsIn: [1, 2, 3, 4, 5, 6, 7])
            return
        }

        type = data.type % 10
        iconImageView.image = UIImage(named: "content.icon.\(data.icon)")

        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }

            switch i {
            case 0:
                textField.text = data.title
            case 1:
                textField.text = "\(data.level)"
            default:
                break
            }
        }
        
        switchButton.isOn = data.type % 10 == 0
        segmentedControl.selectedSegmentIndex = max(0, (data.type / 10) - 1)
    }

    
    func setupGestureRecognizer() {
        iconView.addGestureRecognizer { _ in
            self.coordinator?.presentToIconPickerViewController(self, animated: true)
        }

        stackView.arrangedSubviews.enumerated().forEach { i, view in
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
        
        advancedView.addGestureRecognizer { _ in
            self.coordinator?.pushToAdvancedContentViewController(self.data, animated: true)
        }
        
        switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        segmentedControl.addTarget(self, action: #selector(valueChanged(segmentedControl:)), for: .valueChanged)
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        type = sender.isOn ? 0 : 1
        
        RealmManager.shared.update {
            self.data?.type = self.category + self.type
            self.data?.included.removeAll()
        }
        
        tableView.reloadData()
    }
    
    @objc func valueChanged(segmentedControl: UISegmentedControl) {
        self.category = (segmentedControl.selectedSegmentIndex + 1) * 10
        
        RealmManager.shared.update {
            self.data?.type = self.category + self.type
        }
    }
}

extension EditContentViewController {
    fileprivate func setupNavigationBar() {
        setTitle("컨텐츠 설정".localized, size: 20)
        
        let complete = UIBarButtonItem(title: isUpdated ? "삭제" : "추가", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = isUpdated ? .systemRed : .systemBlue

        addRightBarButtonItems([complete])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        if isUpdated {
            let alert = UIAlertController(title: "컨텐츠 삭제", message: "해당 컨텐츠를 삭제하여\n할 일 관리에서 제외합니다.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "삭제", style: .destructive) { _ in
                guard let data = self.data else { return }
                
                RealmManager.shared.delete(data)
                
                self.coordinator?.popViewController(animated: true)
            }
            
            let no = UIAlertAction(title: "취소", style: .cancel) { _ in }
            
            alert.addAction(no)
            alert.addAction(ok)
            
            self.present(alert, animated: true)
        } else {
            guard let data = self.data,
                    data.title != "" else {
                        Alert.message(self, title: "정보 부족", message: "이름을 확인해주세요", handler: nil)
                        return
                    }
            
            RealmManager.shared.update {
                let todo = RealmManager.shared.readAll(Todo.self).first
                todo?.additional.append(data)
                
                self.coordinator?.popViewController(animated: true)
            }
        }
    }
}


extension EditContentViewController: IconPickerViewDelegate, TextFieldDelegate {
    func pickerView(_ icon: UIImage, didSelectItemAt index: Int) {
        RealmManager.shared.update {
            self.data?.icon = index
            self.iconImageView.image = icon
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let textField = stackView.arrangedSubviews[safe: selectTextFieldAtIndex]?.subviews[safe: 1] as? UITextField else { return }

        textField.text = text
        
        RealmManager.shared.update {
            switch self.selectTextFieldAtIndex {
            case 0: // 이름
                self.data?.title = text
            case 1: // 레벨
                self.data?.level = Double(text) ?? 0.0
            default:
                break
            }
        }
    }
}

extension EditContentViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        tableView.separatorInset = .zero
        tableView.register(UINib(nibName: "CharacterListTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterListTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = RealmManager.shared.readAll(Todo.self).first?.member else { return 0 }
        let filter = data.filter { $0.category == self.type }
        
        return filter.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListTableViewCell", for: indexPath) as! CharacterListTableViewCell
        
        if let data = RealmManager.shared.readAll(Todo.self).first?.member,
           let filter = Array(data.filter({ $0.category == self.type }))[safe: indexPath.row] {

            cell.member = filter
            cell.showContentImageView = true
            
            cell.contentImageView.image = self.data?.included.contains(filter.identifier) ?? false
            ? UIImage(named: "content.icon.26")?.withRenderingMode(.alwaysOriginal)
            : UIImage(named: "content.icon.26")?.withRenderingMode(.alwaysTemplate)
            cell.contentImageView.tintColor = .placeholderText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CharacterListTableViewCell

        if let data = RealmManager.shared.readAll(Todo.self).first?.member,
           let filter = Array(data.filter({ $0.category == self.type }))[safe: indexPath.row] {
            let included = self.data?.included.contains(filter.identifier) ?? false
            
            RealmManager.shared.update {
                if included {
                    guard let index = self.data?.included.firstIndex(of: filter.identifier) else { return }
                    self.data?.included.remove(at: index)
                } else {
                    self.data?.included.append(filter.identifier)
                }
            }
            
            cell.contentImageView.image = self.data?.included.contains(filter.identifier) ?? false
            ? UIImage(named: "content.icon.26")?.withRenderingMode(.alwaysOriginal)
            : UIImage(named: "content.icon.26")?.withRenderingMode(.alwaysTemplate)
            cell.contentImageView.tintColor = .placeholderText
        }
    }
}
