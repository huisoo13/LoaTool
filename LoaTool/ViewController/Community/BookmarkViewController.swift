//
//  BookmarkViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/28.
//

import UIKit

protocol BookmarkDelegate {
    func bookmark(_ viewController: UIViewController, didSelectItem item: Community)
}
    
class BookmarkViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    weak var coordinator: AppCoordinator?

    var delegate: BookmarkDelegate?
    var options: FilterOption {
        let options = FilterOption()
        options.isMarked = true
        return options
    }
    
    var viewModel: CommunityViewModel = CommunityViewModel()
    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupNavigationBar()
        setupTableView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        coordinator?.dismiss(animated: true)
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            if let isRefreshing = self.tableView.cr.header?.isRefreshing, isRefreshing {
                self.tableView.cr.endHeaderRefresh()
            }
            
            if let isRefreshing = self.tableView.cr.footer?.isRefreshing, isRefreshing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.tableView.cr.endLoadingMore()
                    
                    if self.viewModel.numberOfItem == 0 {
                        self.tableView.cr.noticeNoMoreData()
                    }
                })
            }
            
            self.tableView.reloadData()
        }
        
        viewModel.configure(self, options: options)
    }
}

extension BookmarkViewController {
    fileprivate func setupNavigationBar() {
        setTitle("북마크".localized, size: 20)
        
    }
}

extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        tableView.register(UINib(nibName: "BookmarkTableViewCell", bundle: nil), forCellReuseIdentifier: "BookmarkTableViewCell")
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.page = 0
            self.viewModel.options.value = FilterOption()
        }
        
        tableView.cr.addFootRefresh() {
            self.page += 1
            self.viewModel.configure(self, page: self.page, options: self.viewModel.options.value)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "북마크 목록"
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
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell

        cell.data = viewModel.result.value?[safe: indexPath.row]

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.result.value?[safe: indexPath.row] else { return }
        
        delegate?.bookmark(self, didSelectItem: data)
        coordinator?.dismiss(animated: true)
    }
}
