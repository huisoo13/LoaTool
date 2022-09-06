//
//  TodoConfigureViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/12.
//

import UIKit
import AVFoundation

class TodoConfigureViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    
    @IBOutlet weak var characterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    var selectedTextFieldAtIndex: Int = 0
    var step: Int = 1
    var job: String = ""
    
    var sub: [Sub] = []
    var members: [Member] = []
    var contents: [AdditionalContent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()
        setupGestureRecognizer()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupView() {
        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor
        
        stackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray4.cgColor
            view.layer.cornerRadius = 6
        }
    }
    
    func setupGestureRecognizer() {
        jobView.addGestureRecognizer { _ in
            self.coordinator?.presentToJobPickerViewController(self, animated: true)
        }
        
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }
            textField.isUserInteractionEnabled = false
            
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.selectedTextFieldAtIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "이름", keyboardType: .default, animated: true)
                }
            case 1:
                view.addGestureRecognizer { _ in
                    self.selectedTextFieldAtIndex = i
                    self.coordinator?.presentToTextFieldViewController(self, title: "레벨", keyboardType: .decimalPad, animated: true)
                }
            default:
                break
            }
        }
    }
}

extension TodoConfigureViewController {
    fileprivate func setupNavigationBar() {
        setTitle("할 일 설정".localized, size: 20)
        
        let reset = UIBarButtonItem(title: step == 1 ? "다음" : "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        reset.tintColor = .systemBlue
        
        addRightBarButtonItems([reset])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        switch step {
        case 1:
            nextToStep()
        case 2:
            let alert = UIAlertController(title: "설정 완료", message: "설정한 데이터를 저장할까요?\n저장한 데이터는 수정이 가능합니다.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "완료", style: .default) { _ in
                self.completedConfigure()
            }
            
            let no = UIAlertAction(title: "취소", style: .destructive) { _ in }
            
            alert.addAction(no)
            alert.addAction(ok)
            
            self.present(alert, animated: true)
        default:
            break
        }
    }
    
    func nextToStep() {
        IndicatorView.showLoadingView()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (_) in
            self.step = 2
            self.setupNavigationBar()
            self.tableView.reloadData()

            self.characterView.isHidden = true
            
            if self.job != "", self.nameTextField.text != "", self.levelTextField.text != "", self.members.count == 0 {
                self.members.append(Member(identifier: UUID().uuidString,
                                           category: 1,
                                           name: self.nameTextField.text ?? "",
                                           job: self.job,
                                           level: Double(self.levelTextField.text ?? "0") ?? 0,
                                           contents: Content.character)
                )
            }
            
            IndicatorView.hideLoadingView()
        })
    }
    
    func completedConfigure() {
        UserDefaults.standard.set(true, forKey: "showDailyContents")
        UserDefaults.standard.set(true, forKey: "showSpectialContents")
        UserDefaults.standard.set(true, forKey: "showAdditionalContents")

        
        // 선택한 컨텐츠의 레벨에 맞는 캐릭터 넣기
        let expedition = Member.expedition

        contents.forEach { content in
            switch content.type % 10 {
            case 0:
                content.included.append(expedition.identifier)
            case 1:
                members.forEach { member in
                    if content.level <= member.level { content.included.append(member.identifier) }
                }
            default:
                break
            }
        }
        
        // 데이터 생성
        let todo = Todo()
        
        todo.identifier = UUID().uuidString
        todo.member.append(expedition)
        todo.member.append(objectsIn: members)
        todo.additional.append(objectsIn: contents)
        todo.gold.append(objectsIn: members.map({ $0.identifier }))
        
        todo.lastUpdate = DateManager.shared.currentDate()
        todo.nextLoaWeekday = DateManager.shared.nextLoaWeekday(DateManager.shared.currentDate())
        
        // 데이터 저장
        RealmManager.shared.add(todo)
        coordinator?.popViewController(animated: true)
    }
}


extension TodoConfigureViewController: TextFieldDelegate, JobPickerViewDelegate {
    func pickerView(_ symbol: UIImage, job: String, didSelectItemAt index: Int) {
        self.job = job
        
        jobImageView.image = symbol
    }
    
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        switch selectedTextFieldAtIndex {
        case 0:
            parsingUserData(text)
        case 1:
            guard let textField = stackView.arrangedSubviews[safe: 1]?.subviews[safe: 1] as? UITextField else { return }
            
            textField.text = text
        default:
            break
        }
    }
    
    func parsingUserData(_ text: String) {
        if text == "" { return }
        
        IndicatorView.showLoadingView()
        Parsing.shared.downloadHTML(text, type: [.stats, .equip, .engrave, .gem, .card]) { data, error in
            switch error {
            case .notFound:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "캐릭터명을 다시 확인해주세요.").present()
                IndicatorView.hideLoadingView()
            case .websiteInspect:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "로스트아크 공식 홈페이지가 점검 중입니다.").present()
                IndicatorView.hideLoadingView()
            case .unknown:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "알 수 없는 오류가 발생했습니다.").present()
                IndicatorView.hideLoadingView()
            case nil:
                let list = data?.info?.memberList
                    .components(separatedBy: " ")
                    .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                    .filter({ $0 != "" }) ?? []
                
                Parsing.shared.downloadHTML(parsingMemberListWith: list) { sub in
                    guard let sub = sub else {
                        return
                    }

                    self.sub = sub
                    self.tableView.reloadData()

                    IndicatorView.hideLoadingView()
                }
            }


            self.jobImageView.image = data?.info?.job.getSymbol()
            
            self.stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let textField = view.subviews[safe: 1] as? UITextField else { return }
                
                switch i {
                case 0:
                    textField.text = text
                case 1:
                    textField.text = String(data?.info?.level ?? 0)
                default:
                    break
                }
            }
        }
    }
}


extension TodoConfigureViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "CharacterListTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterListTableViewCell")
        tableView.register(UINib(nibName: "ContentListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentListTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = step == 1 ? "보유 캐릭터" : "컨텐츠 프리셋"
        header.typeView.isHidden = step == 1
        header.button.isHidden = true
        
        return header

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        step == 1 ?  sub.count : AdditionalContent.preset.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch step {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListTableViewCell", for: indexPath) as! CharacterListTableViewCell
            
            cell.data = sub[indexPath.row]
            cell.showSwitchButton = true
            cell.switchButton.addTarget(self, action: #selector(valueChangedSwitchButton(_:)), for: .valueChanged)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentListTableViewCell", for: indexPath) as! ContentListTableViewCell
            
            cell.data = AdditionalContent.preset[indexPath.row]
            cell.showSwitchButton = true
            cell.switchButton.addTarget(self, action: #selector(valueChangedSwitchButton(_:)), for: .valueChanged)
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    @objc func valueChangedSwitchButton(_ sender: UISwitch) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: position) else { return }
        
        switch step {
        case 1:
            guard let data = sub[safe: indexPath.row],
                  let name = data.name.components(separatedBy: " ").last else { return }
            
            if sender.isOn {
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
                
                members.append(Member(identifier: UUID().uuidString,
                                      category: 1,
                                      name: name,
                                      job: data.job,
                                      level: data.level,
                                      contents: contents)
                )
            } else {
                members = members.filter { $0.name != name }
            }
            
            members.sort(by: { ($1.level , $0.name) < ($0.level, $1.name) })
        case 2:
            if sender.isOn {
                contents.append(AdditionalContent.preset[indexPath.row])
            } else {
                contents = contents.filter { $0.identifier != AdditionalContent.preset[indexPath.row].identifier }
            }
            
            contents.sort(by: { $0.identifier < $1.identifier })            
        default:
            break
        }
    }
}
