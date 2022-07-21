//
//  CharacterListViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

protocol CharacterListDelegate {
    /**
     CharacterListDelegate
     
     - parameters:
        - server: 선택한 캐릭터의 서버
        - name: 선택한 캐릭터의 이름
     */
    func character(_ server: String, didSelectRowAt name: String)
}

class CharacterListViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    weak var coordinator: AppCoordinator?
    
    var delegate: CharacterListDelegate?
    var memberList: [String] = []
    
    var sub: [Sub] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupData()
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        coordinator?.dismiss(animated: true)
    }
    
    func setupData() {
        let list = memberList

        indicatorView.isHidden = false
        Parsing.shared.downloadHTML(parsingMemberListWith: list) { sub in
            self.indicatorView.isHidden = true
            guard let sub = sub else { return }

            self.sub = sub
            self.tableView.reloadData()
        }
    }
}

extension CharacterListViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "CharacterListTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterListTableViewCell")

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let server = Set(sub.map { $0.server })
                
        return server.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView

        let server = Array(Set(sub.map { $0.server })).sorted(by: { $0 < $1 })

        header.label.text = server[section]
        
        header.typeView.isHidden = true
        header.button.isHidden = true

        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let server = Array(Set(sub.map { $0.server })).sorted(by: { $0 < $1 })
        let data = sub.filter { $0.server == server[section] }
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListTableViewCell", for: indexPath) as! CharacterListTableViewCell
                
        let server = Array(Set(sub.map { $0.server })).sorted(by: { $0 < $1 })
        let data = sub.filter { $0.server == server[indexPath.section] }.sorted(by: { ($1.level, $0.name) < ($0.level, $1.name) })

        cell.data = data[indexPath.row]
        cell.showChevornView = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = Array(Set(sub.map { $0.server })).sorted(by: { $0 < $1 })
        let data = sub.filter { $0.server == server[indexPath.section] }.sorted(by: { ($1.level, $0.name) < ($0.level, $1.name) })
        
        delegate?.character(data[indexPath.row].server, didSelectRowAt: data[indexPath.row].name.components(separatedBy: " ").last ?? "")
        coordinator?.dismiss(animated: true)
    }
}
