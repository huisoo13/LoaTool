//
//  CalculatorResultCollectionViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/17.
//

import UIKit

class CalculatorResultCollectionViewCell: UICollectionViewCell {

    @IBOutlet var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupTableView()
    }
}

extension CalculatorResultCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemGroupedBackground

        tableView.separatorInset = .zero
        tableView.contentInset = .zero

        tableView.register(UINib(nibName: "CalculatorResultHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CalculatorResultHeaderView")
        tableView.register(UINib(nibName: "CalculatorResultTableViewCell", bundle: nil), forCellReuseIdentifier: "CalculatorResultTableViewCell")

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CalculatorResultHeaderView") as! CalculatorResultHeaderView

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorResultTableViewCell", for: indexPath) as! CalculatorResultTableViewCell
        
        
        return cell
    }
}
