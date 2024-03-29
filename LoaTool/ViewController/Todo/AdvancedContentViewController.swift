//
//  AdvancedContentViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/08/29.
//

import UIKit

class AdvancedContentViewController: UIViewController, Storyboarded {
    @IBOutlet weak var linkTitleView: UIView!
    @IBOutlet weak var infoView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var goldView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var limitView: UIView!
    
    weak var coordinator: AppCoordinator?
    
    var data: AdditionalContent?
    var selectTextFieldAtIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupData()
        setupView()
        setupGestureRecognizer()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setupView() {
        switchButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        guard let data = self.data else { return }
        limitView.isUserInteractionEnabled = data.allowLimit
        limitView.subviews.forEach { view in
            view.alpha = data.allowLimit ? 1 : 0.5
            view.isUserInteractionEnabled = data.allowLimit
        }
        
        linkTitleView.isHidden = data.type / 10 != 4
        tableView.isHidden = data.type / 10 != 4
    }
    
    func setupData() {
        guard let data = data else { return }
        
        switchButton.isOn = data.allowLimit
        if let levelTextField = limitView.subviews.first as? UITextField {
            levelTextField.text = String(data.limit)
        }
        
        guard let goldTextField = goldView.subviews.first as? UITextField else { return }
        goldTextField.text = data.gold.withCommas()
    }
    
    
    func setupGestureRecognizer() {
        linkTitleView.addGestureRecognizer { _ in
            self.infoView.arrangedSubviews.forEach { view in
                view.isHidden = !view.isHidden
            }
        }
        
        goldView.addGestureRecognizer { _ in
            self.selectTextFieldAtIndex = 0
            self.coordinator?.presentToTextFieldViewController(self, title: "획득 골드", keyboardType: .numberPad, animated: true)
        }
        
        limitView.addGestureRecognizer { _ in
            self.selectTextFieldAtIndex = 1
            self.coordinator?.presentToTextFieldViewController(self, title: "골드 획득 제한 레벨", keyboardType: .numberPad, animated: true)
        }
        
        switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        RealmManager.shared.update {
            self.data?.allowLimit = sender.isOn
        }
        
        limitView.isUserInteractionEnabled = sender.isOn
        limitView.subviews.forEach { view in
            view.alpha = sender.isOn ? 1 : 0.5
            view.isUserInteractionEnabled = sender.isOn
        }
    }
}

extension AdvancedContentViewController {
    fileprivate func setupNavigationBar() {
        setTitle("고급 설정".localized, size: 20)
    }
}


extension AdvancedContentViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text else { return }
        switch selectTextFieldAtIndex {
        case 0:
            guard let textField = goldView.subviews.first as? UITextField else { return }
            RealmManager.shared.update {
                self.data?.gold = Int(text) ?? 0
            }
            
            textField.text = (Int(text) ?? 0).withCommas()
        case 1:
            guard let textField = limitView.subviews.first as? UITextField else { return }
            RealmManager.shared.update {
                self.data?.limit = Double(text) ?? 0.0
            }
            
            textField.text = text
        default:
            break
        }
        

    }
}

extension AdvancedContentViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.separatorInset = .zero
        tableView.register(UINib(nibName: "ContentListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentListTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = RealmManager.shared.readAll(Todo.self).first?.additional else { return 0 }
        
        let filter = Array(data).filter { $0.type / 10 == 4 && $0.identifier != self.data?.identifier ?? "" }
        
        return filter.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentListTableViewCell", for: indexPath) as! ContentListTableViewCell
        
        if let data = RealmManager.shared.readAll(Todo.self).first?.additional,
           let filter = Array(data.filter({  $0.type / 10 == 4 && $0.identifier != self.data?.identifier ?? "" }))[safe: indexPath.row] {
            
            cell.data = filter
            cell.showLinkView = true
            
            guard let commander = cell.linkView.subviews[safe: 1] as? UIImageView,
                  let gate = cell.linkView.subviews.last as? UIImageView else { return cell }
            commander.isHidden = (filter.link != self.data?.link || filter.link == "") || (filter.gate == self.data?.gate && filter.gate != "")
            gate.isHidden = filter.gate != self.data?.gate || filter.gate == ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = RealmManager.shared.readAll(Todo.self).first?.additional,
           let filter = Array(data.filter({  $0.type / 10 == 4 && $0.identifier != self.data?.identifier ?? ""  }))[safe: indexPath.row],
           var link = self.data?.link,
           var gate = self.data?.gate {
            
            link = link == "" ? UUID().uuidString : link
            gate = gate == "" ? UUID().uuidString : gate
            
            let isLinkingContent = link == filter.link
            let isSameGateContent = gate == filter.gate
 
            RealmManager.shared.update {
                if (!isLinkingContent && !isSameGateContent) || (isLinkingContent && isSameGateContent) {
                    self.data?.link = link
                    filter.link = self.data?.link == filter.link ? "" : link
                }
                
                if !isLinkingContent { return }
                
                self.data?.gate = gate
                if gate == filter.gate {
                    filter.gate = ""
                } else {
                    data.forEach { data in
                        if data.identifier != self.data?.identifier && data.gate == gate && data.type / 10 == 4 {
                            data.gate = ""
                        }
                    }
                    
                    filter.gate = gate
                }
            }

            tableView.reloadData()
        }
    }
}
