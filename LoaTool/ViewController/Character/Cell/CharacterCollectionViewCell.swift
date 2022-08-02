//
//  CharacterCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tableView: UITableView!
    
    var type: Int = 0
    var selectedInfo: Bool = false
    var selectedEquip: Int = -1
    var selectedAccessory: Int = -1
    var selectedGem: Bool = false

    var data: Character? {
        didSet {
            guard let _ = data else {
                return
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableView()
    }
}
 
extension CharacterCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        tableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
        tableView.register(UINib(nibName: "EquipTableViewCell", bundle: nil), forCellReuseIdentifier: "EquipTableViewCell")
        tableView.register(UINib(nibName: "AccessoryTableViewCell", bundle: nil), forCellReuseIdentifier: "AccessoryTableViewCell")
        tableView.register(UINib(nibName: "GemTableViewCell", bundle: nil), forCellReuseIdentifier: "GemTableViewCell")
        tableView.register(UINib(nibName: "SkillTableViewCell", bundle: nil), forCellReuseIdentifier: "SkillTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        type == 0 ? 4 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        type == 0 ? 1 : (data?.skill.count ?? 10)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView

        switch section {
        case 0:
            header.label.text = type == 0 ? "기본 정보" : "스킬"
        case 1:
            header.label.text = "장비"
        case 2:
            header.label.text = "장신구"
        case 3:
            header.label.text = "보석"
        default:
            break
        }
        
        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if type == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as! InfoTableViewCell
                
                cell.isSelectedItem = selectedInfo
                cell.data = data
                cell.addGestureRecognizer { _ in
                    self.selectedInfo = !self.selectedInfo
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SkillTableViewCell", for: indexPath) as! SkillTableViewCell
                
                cell.data = data?.skill[indexPath.row]
                
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EquipTableViewCell", for: indexPath) as! EquipTableViewCell
            
            cell.selectedPosition = selectedEquip
            cell.data = data?.equip.map { $0 }
            
            cell.itemViews.forEach { view in
                view.addGestureRecognizer { _ in
                    self.selectedEquip = view.tag
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                }
            }
            
            cell.detailView.addGestureRecognizer { _ in
                self.selectedEquip = -1
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
            }
            
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryTableViewCell", for: indexPath) as! AccessoryTableViewCell
            
            cell.selectedPosition = selectedAccessory
            cell.data = data

            cell.itemViews.forEach { view in
                if view.tag == 27 { return }
                view.addGestureRecognizer { _ in
                    self.selectedAccessory = view.tag
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                }
            }
            
            cell.detailView.addGestureRecognizer { _ in
                self.selectedAccessory = -1
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GemTableViewCell", for: indexPath) as! GemTableViewCell
            
            cell.isSelectedItem = selectedGem
            cell.data = data
        
            return cell

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:     // 보석이 없는 경우 아이템이 안보이기 때문에 별도로 작성
            self.selectedGem = !self.selectedGem
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
        default:
            break
        }
    }
}
