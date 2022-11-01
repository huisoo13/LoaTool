//
//  ContentPresetViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/01.
//

import UIKit

class ContentPresetViewController: UIViewController, Storyboarded {
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

extension ContentPresetViewController {
    fileprivate func setupNavigationBar() {
        setTitle("컨텐츠 프리셋".localized, size: 20)
    }
}

extension ContentPresetViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "ContentListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentListTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "컨텐츠 프리셋"
        header.typeView.isHidden = false
        header.button.isHidden = true
        
        return header

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AdditionalContent.preset.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentListTableViewCell", for: indexPath) as! ContentListTableViewCell
        
        cell.data = AdditionalContent.preset[indexPath.row]
        cell.showSwitchButton = false
        cell.showChevornView = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = AdditionalContent.preset[indexPath.row]
        content.identifier = UUID().uuidString
        
        coordinator?.pushToEditContentViewController(content, animated: true)
    }
}
