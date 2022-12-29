//
//  TodoManagementViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/31.
//

import UIKit

class TodoManagementViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    let viewModel: TodoViewModel = TodoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.configure()

        NotificationCenter.default.addObserver(self, selector: #selector(beginUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("beginUpdateRealmFromCloudKit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("beginUpdateRealmFromCloudKit"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
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
        }
    }
    
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            self.tableView.reloadData()
        }        
    }
}

extension TodoManagementViewController {
    fileprivate func setupNavigationBar() {
        setTitle("할 일 관리".localized, size: 20)
        
        let reset = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        
        let menu = createMenuBarButtonItem()

        addRightBarButtonItems([menu, reset])
    }
    
    func createMenuBarButtonItem() -> UIBarButtonItem {
        let character = UIAction(title: "", subtitle: "캐릭터 추가", image: nil, identifier: nil) { _ in
            self.coordinator?.pushToEditCharacterViewController(nil, animated: true)
        }
        
        let content = UIAction(title: "", subtitle: "컨텐츠 추가", image: nil, identifier: nil) { _ in
            self.coordinator?.pushToEditContentViewController(nil, animated: true)
        }

        let menu = UIMenu(title: "추가하기", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [character, content])
        
        let barButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .thin)), primaryAction: nil, menu: menu)
        
        return barButtonItem
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "초기화", message: "모든 완료 항목을 초기화할까요?\n초기화 하지 않아도 로요일에 자동 초기화됩니다.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "초기화", style: .destructive) { _ in
            self.viewModel.updateContentManually()
        }
        
        let no = UIAlertAction(title: "취소", style: .cancel) { _ in }
        
        alert.addAction(ok)
        alert.addAction(no)
        
        self.present(alert, animated: true)
    }
}

extension TodoManagementViewController: UITableViewDelegate, UITableViewDataSource, TableViewReorderDelegate {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
        tableView.reorder.delegate = self
                
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        
        tableView.register(UINib(nibName: "CharacterListTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterListTableViewCell")
        tableView.register(UINib(nibName: "ContentListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentListTableViewCell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = section == 0 ? "캐릭터" : "컨텐츠"
        header.button.setTitle(section == 0 ? "캐릭터 정보 자동 갱신" : "컨텐츠 프리셋 보기", for: .normal)
        header.button.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)

        header.typeView.isHidden = true
        header.button.isHidden = false // section == 1
        
        return header
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            switch indexPath.section {
            case 0:
                let alert = UIAlertController(title: "정보 갱신", message: "캐릭터의 정보를 갱신합니다.\n등록 캐릭터의 수가 많을수록 시간이 오래 걸립니다.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "갱신", style: .default) { _ in
                    self.viewModel.updateMemberInfo()
                }
                
                let no = UIAlertAction(title: "취소", style: .destructive) { _ in }
                
                alert.addAction(no)
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            case 1:
                coordinator?.pushToContentPresetViewController(animated: true)
            default:
                break
            }
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            let member = viewModel.result.value?.member.filter({ $0.category != 0 })
            return member?.count ?? 0
        case 1:
            let content = viewModel.result.value?.additional
            return content?.count ?? 0
        default:
            break
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reorder
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListTableViewCell", for: indexPath) as! CharacterListTableViewCell
            
            if let data = viewModel.result.value {
                cell.member = Array(data.member.filter { $0.category != 0 })[safe: indexPath.row]
                cell.showChevornView = true
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentListTableViewCell", for: indexPath) as! ContentListTableViewCell
            let content = viewModel.result.value?.additional
            
            cell.data = content?[safe: indexPath.row]
            cell.showChevornView = true

            return cell
        default:
            break
        }

        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let data = viewModel.result.value {
                let member = Array(data.member.filter { $0.category != 0 })[safe: indexPath.row]
                coordinator?.pushToEditCharacterViewController(member, animated: true)
            }
        case 1:
            if let data = viewModel.result.value {
                let content = data.additional[safe: indexPath.row]
                coordinator?.pushToEditContentViewController(content, isUpdated: true, animated: true)
            }
        default:
            break
        }
    }
    
    // MARK: TableViewReorderDelegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == destinationIndexPath.section,
              sourceIndexPath.row != destinationIndexPath.row else { return }

        RealmManager.shared.update {
            switch sourceIndexPath.section {
            case 0:
                guard let member = self.viewModel.result.value?.member[safe: sourceIndexPath.row + 1] else { return }

                self.viewModel.result.value?.member.remove(at: sourceIndexPath.row + 1)
                self.viewModel.result.value?.member.insert(member, at: destinationIndexPath.row + 1)
            case 1:
                guard let additional = self.viewModel.result.value?.additional[safe: sourceIndexPath.row] else { return }

                self.viewModel.result.value?.additional.remove(at: sourceIndexPath.row)
                self.viewModel.result.value?.additional.insert(additional, at: destinationIndexPath.row)
            default:
                break
            }
        }
    }
}


