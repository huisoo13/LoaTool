//
//  TodoViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/28.
//

import UIKit

class TodoViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpView: UIView!
    
    var goldLabel: UILabel?
    
    weak var coordinator: AppCoordinator?
    
    let viewModel: TodoViewModel = TodoViewModel()
    

    var showDailyContents: Bool = UserDefaults.standard.bool(forKey: "showDailyContents")
    var showSpectialContents: Bool = UserDefaults.standard.bool(forKey: "showSpectialContents")
    var showAdditionalContents: Bool = UserDefaults.standard.bool(forKey: "showAdditionalContents")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(beginUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("beginUpdateRealmFromCloudKit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
        
        CloudManager.shared.pull([Todo.self]) { error in
            guard error == nil else { return }
            debug("iCloud 에서 할 일 정보 가져오기")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: NSNotification.Name(rawValue: "reloadData"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("beginUpdateRealmFromCloudKit"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
    
    @objc func beginUpdateRealmFromCloudKit(_ sender: NSNotification) {
        DispatchQueue.main.async {
            IndicatorView.showLoadingView()
        }
    }
    
    @objc func endUpdateRealmFromCloudKit(_ sender: NSNotification) {
        DispatchQueue.main.async {
            IndicatorView.hideLoadingView()
            self.viewModel.configure()
            
            CloudManager.shared.timerForTodo?.invalidate()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.reloadData()
        }, completion: { _ in
            self.tableView.reloadData()
        })
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            self.tableView.reloadData()
        }
        
        viewModel.isNil.bind { isNil in
            if let isNil = isNil {
                self.helpView.isHidden = !isNil
                self.tableView.isHidden = isNil
            }
        }
    }
    
    @IBAction func moveToTodoConfigureViewController(_ sender: UIButton) {
        coordinator?.pushToTodoConfigureViewController(animated: true)
    }
    
    @objc func reloadData(_ sender: NSNotification) {
        goldLabel?.text = totalClearGold().withCommas()
    }
    
    func totalClearGold() -> Int {
        var gold = 0
        let acquired = viewModel.result.value?.gold
        
        viewModel.result.value?.additional.forEach { additional in
            additional.takenGold.forEach { completed in
                guard let allow = acquired?.contains(completed),
                      let member = RealmManager.shared.read(Member.self, identifier: completed).first,
                      allow else { return }
                
                switch (additional.allowLimit, member.level < additional.limit) {
                case (true, false):
                    break
                default:
                    gold += additional.gold
                }
            }
        }
        
        return gold
    }
}

extension TodoViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        tableView.register(UINib(nibName: "DailyTableViewCell", bundle: nil), forCellReuseIdentifier: "DailyTableViewCell")
        tableView.register(UINib(nibName: "SpecialDailyTableViewCell", bundle: nil), forCellReuseIdentifier: "SpecialDailyTableViewCell")
        tableView.register(UINib(nibName: "AdditionalTableViewCell", bundle: nil), forCellReuseIdentifier: "AdditionalTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        switch section {
        case 0:
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = showDailyContents
            ? UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .light))?.withTintColor(.label)
            : UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .light))?.withTintColor(.label)

            imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

            let attachmentString = NSAttributedString(attachment: imageAttachment)

            let completeText = NSMutableAttributedString(string: "")
            completeText.append(attachmentString)

            let textAfterIcon = NSAttributedString(string: " 원정대")
            completeText.append(textAfterIcon)
            
            header.label.textAlignment = .center
            header.label.attributedText = completeText
        case 1:
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = showSpectialContents
            ? UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .light))?.withTintColor(.label)
            : UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .light))?.withTintColor(.label)

            imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

            let attachmentString = NSAttributedString(attachment: imageAttachment)

            let completeText = NSMutableAttributedString(string: "")
            completeText.append(attachmentString)

            let textAfterIcon = NSAttributedString(string: " 고정 컨텐츠")
            completeText.append(textAfterIcon)
            
            header.label.textAlignment = .center
            header.label.attributedText = completeText
        case 2:
            header.label.text = "추가 컨텐츠"
            
            if let label = header.goldView.subviews[safe: 1] as? UILabel { goldLabel = label }
            goldLabel?.text = totalClearGold().withCommas()
        default:
            break
        }
        
        header.typeView.isHidden = section != 0
        header.button.isHidden = true
        header.goldView.isHidden = section != 2
        
        header.addGestureRecognizer { _ in
            switch section {
            case 0:
                self.showDailyContents = !self.showDailyContents
                UserDefaults.standard.set(self.showDailyContents, forKey: "showDailyContents")
            case 1:
                self.showSpectialContents = !self.showSpectialContents
                UserDefaults.standard.set(self.showSpectialContents, forKey: "showSpectialContents")
            case 2:
                self.showAdditionalContents = !self.showAdditionalContents
                UserDefaults.standard.set(self.showAdditionalContents, forKey: "showAdditionalContents")
            default:
                break
            }

            self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section != 2 ? 1 : (viewModel.result.value?.additional.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return showDailyContents ? UITableView.automaticDimension : 2
        case 1:
            return showSpectialContents ? 144 : 2
        case 2:
            return 60
        default:
            break
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyTableViewCell", for: indexPath) as! DailyTableViewCell

            if let data = viewModel.result.value {
                cell.data = Array(data.member.filter { $0.category != 0 })
                cell.coordinator = coordinator
                cell.contentView.isHidden = !showDailyContents
            }
            

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialDailyTableViewCell", for: indexPath) as! SpecialDailyTableViewCell
            
            if let data = viewModel.result.value {
                cell.data = data.member.first
                cell.contentView.isHidden = !showSpectialContents
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdditionalTableViewCell", for: indexPath) as! AdditionalTableViewCell
            
            cell.data = viewModel.result.value?.additional[safe: indexPath.row]
            cell.target = self
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 수정 - 003
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        //
        
        if indexPath.section == 2 && !showExcludedMember {
            let cell = tableView.cellForRow(at: indexPath) as! AdditionalTableViewCell
            cell.showCharacterList = !(cell.showCharacterList ?? false)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 수정 - 003
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        //
        if indexPath.section == 2 && !showExcludedMember {
            let cell = tableView.cellForRow(at: indexPath) as! AdditionalTableViewCell
            cell.showCharacterList = !(cell.showCharacterList ?? false)
        }
    }
}
