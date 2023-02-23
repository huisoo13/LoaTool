//
//  CalculatorCollectionViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit

class CalculatorCollectionViewCell: UICollectionViewCell {

    @IBOutlet var tableView: UITableView!
    weak var coordinator: AppCoordinator?

    var index: Int = 0
    var data: Calculator? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupTableView()
    }
}

extension CalculatorCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemGroupedBackground

        tableView.separatorInset = .zero
        tableView.contentInset = .zero

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "CalculatorHelpTableViewCell", bundle: nil), forCellReuseIdentifier: "CalculatorHelpTableViewCell")
        tableView.register(UINib(nibName: "CalculatorTargetTableViewCell", bundle: nil), forCellReuseIdentifier: "CalculatorTargetTableViewCell")
        tableView.register(UINib(nibName: "CalculatorEquipmentTableViewCell", bundle: nil), forCellReuseIdentifier: "CalculatorEquipmentTableViewCell")
        tableView.register(UINib(nibName: "CalculatorAccessoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CalculatorAccessoryTableViewCell")

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return index == 0 ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView

        switch (index, section) {
        case (0, 0):
            header.label.text = "안내"
        case (0, 1):
            header.label.text = "목표 각인 설정"
        case (1, 0):
            header.label.text = "장착 각인 설정"
        case (1, 1):
            header.label.text = "어빌리티 스톤 설정"
        case (1, 2):
            header.label.text = "악세서리 설정"
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

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (index, section) {
        case (0, 0):
            return 1
        case (0, 1):
            return 7
        case (1, 0):
            return 2
        case (1, 1):
            return 3
        case (1, 2):
            return 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (index, indexPath.section) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorHelpTableViewCell", for: indexPath) as! CalculatorHelpTableViewCell
            
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorTargetTableViewCell", for: indexPath) as! CalculatorTargetTableViewCell
            
            cell.coordinator = coordinator
            cell.row = indexPath.row
            cell.data = data?.targetEngraving[safe: indexPath.row]
            
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorEquipmentTableViewCell", for: indexPath) as! CalculatorEquipmentTableViewCell
            
            cell.coordinator = coordinator
            cell.row = indexPath.row
            cell.isAbillityStone = false
            cell.data = data?.equipEngraving[safe: indexPath.row]
            
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorEquipmentTableViewCell", for: indexPath) as! CalculatorEquipmentTableViewCell
            
            cell.coordinator = coordinator
            cell.row = indexPath.row
            cell.isAbillityStone = true
            cell.isPenalty = indexPath.row == 2
            cell.data = data?.abillityStone[safe: indexPath.row]
            
            return cell
        case (1, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorAccessoryTableViewCell", for: indexPath) as! CalculatorAccessoryTableViewCell
            
            cell.coordinator = coordinator
            switch indexPath.row {
            case 0:
                cell.accessory = data?.necklace
            case 1:
                cell.accessory = data?.earring1
            case 2:
                cell.accessory = data?.earring2
            case 3:
                cell.accessory = data?.ring1
            case 4:
                cell.accessory = data?.ring2
            default:
                break
            }
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    
    
    
}
