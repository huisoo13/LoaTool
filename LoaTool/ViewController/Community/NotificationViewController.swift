//
//  NotificationViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/10.
//

import UIKit

class NotificationViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?

    var viewModel = NotificationViewModel()
    
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

extension NotificationViewController {
    fileprivate func setupNavigationBar() {
        setTitle("알림".localized, size: 20)
                
        let complete = UIBarButtonItem(title: "모든 알림 읽기", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = .systemBlue

        addRightBarButtonItems([complete])
    }
        
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        IndicatorView.showLoadingView(title: "확인 중입니다.")
        API.post.updateNotification() { result in
            self.viewModel.configure(self)
            self.tableView.reloadData()
            IndicatorView.hideLoadingView()
        }
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
                        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.viewModel.configure(self)
        }
    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "알림 목록"

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.data = viewModel.result.value?[safe: indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.result.value?[safe: indexPath.row],
              let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell else { return }
        
        
        DispatchQueue.global(qos: .background).async {
            API.post.updateNotification(data.identifier) { result in
                self.viewModel.result.value?[safe: indexPath.row]?.isRead = true
                cell.data = self.viewModel.result.value?[safe: indexPath.row]
            }
        }
        
        switch data.type {
        case 0, 1, 2:
            API.get.selectSinglePost(self, post: data.post) { post in
                self.coordinator?.pushToPostViewController(post, notification: data, animated: true)
            }
        case -10:
            API.get.selectSinglePost(self, post: data.post) { post in
                self.coordinator?.pushToPostViewController(post, notification: data, animated: true)
            }
        case -20:
            // 경고
            break
        default:
            break
        }
    }
}
