//
//  BlockViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/28.
//

import UIKit

class BlockViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?

    var viewModel = BlockViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            if let isRefreshing = self.tableView.cr.header?.isRefreshing, isRefreshing {
                self.tableView.cr.endHeaderRefresh()
            }
            
            self.tableView.reloadData()
        }
        
        viewModel.configure(self)
    }
}

extension BlockViewController {
    fileprivate func setupNavigationBar() {
        setTitle("차단 목록".localized, size: 20)
    }
}

extension BlockViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "BlockTableViewCell", bundle: nil), forCellReuseIdentifier: "BlockTableViewCell")
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.viewModel.configure(self)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "목록"

        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.result.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTableViewCell", for: indexPath) as! BlockTableViewCell
        
        cell.data = viewModel.result.value?[safe: indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let data = viewModel.result.value?[safe: indexPath.row] else { return nil }

        let block = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            Alert.message(self, title: "차단 해제", message: "해당 작성자의 글을 다시 확인할 수 있습니다.", option: .successAndCancelAction) { _ in
                self.viewModel.update(self, identifier: data.identifier) { result in
                    self.viewModel.configure(self)
                }
            }
            
            completionHandler(true)
            
        }
        
        block.backgroundColor = .separator
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        label.text = "해제"
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .clear
        
        block.image = UIImage(view: label)?.withTintColor(.lightGray).withRenderingMode(.alwaysOriginal)

        let swipeAction = UISwipeActionsConfiguration(actions: [block])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return swipeAction
    }
}
