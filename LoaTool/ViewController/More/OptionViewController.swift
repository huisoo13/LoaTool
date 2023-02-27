//
//  OptionViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/08/03.
//

import UIKit

class OptionViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
}

extension OptionViewController {
    fileprivate func setupNavigationBar() {
        setTitle("환경 설정".localized, size: 20)
    }
}

extension OptionViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "OptionTableViewCell", bundle: nil), forCellReuseIdentifier: "OptionTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "할 일"

        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTableViewCell", for: indexPath) as! OptionTableViewCell
        
        switch indexPath.row {
        case 0:
            let isOn = UserDefaults.standard.bool(forKey: "showBonusView")
            cell.setup("휴식 보너스 시각화", description: "휴식 보너스를 게이지 형식으로 보여줍니다.", isOn: isOn, switchButton: false)
        case 1:
            let isOn = UserDefaults.standard.bool(forKey: "showUnselectedItem")
            cell.setup("선택 안된 캐릭터명 보기", description: "슬라이드에서 선택되지 않은 캐릭터명을 보여줍니다.", isOn: isOn, switchButton: false)
        case 2:
            let isOn = UserDefaults.standard.bool(forKey: "showExcludedMember")
            cell.setup("추가 컨텐츠 스크롤 그룹화", description: "추가 컨텐츠의 보기 방식을 개별에서 그룹으로 변경합니다.", isOn: isOn, switchButton: false)
        case 3:
            let isOn = UserDefaults.standard.bool(forKey: "usingTakenGold")
            cell.setup("골드 보상 획득 여부 선택", description: "컨텐츠 완료 시 골드 보상 획득 여부를 선택하며, 엔드 컨텐츠를 3회 이상 완료 표시 할 수 있습니다.", isOn: isOn, switchButton: false)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        
        switch indexPath.row {
        case 0:
            let isOn = UserDefaults.standard.bool(forKey: "showBonusView")
            UserDefaults.standard.set(!isOn, forKey: "showBonusView")
            
            cell.switchButton.setOn(!isOn, animated: true)
        case 1:
            let isOn = UserDefaults.standard.bool(forKey: "showUnselectedItem")
            UserDefaults.standard.set(!isOn, forKey: "showUnselectedItem")
            
            cell.switchButton.setOn(!isOn, animated: true)
        case 2:
            let isOn = UserDefaults.standard.bool(forKey: "showExcludedMember")
            UserDefaults.standard.set(!isOn, forKey: "showExcludedMember")
            
            cell.switchButton.setOn(!isOn, animated: true)
        case 3:
            let isOn = UserDefaults.standard.bool(forKey: "usingTakenGold")
            UserDefaults.standard.set(!isOn, forKey: "usingTakenGold")
            
            cell.switchButton.setOn(!isOn, animated: true)
        default:
            break
        }
    }
}
