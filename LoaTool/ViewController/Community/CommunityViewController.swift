//
//  CommunityViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/20.
//

import UIKit

class CommunityViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    static var reloadToData: Bool = false
    static var options = FilterOption()
    
    var viewModel: CommunityViewModel = CommunityViewModel()
    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CommunityViewController.reloadToData {
            viewModel.options.value = CommunityViewController.options
        }
        
        setupAccount()
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
            guard let result = result else { return }

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
            
            if CommunityViewController.reloadToData {
                CommunityViewController.reloadToData = false
                if result.count > 1 { self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false) }
            }
        }
        
        viewModel.options.bind { options in
            guard let options = options else { return }
            self.viewModel.configure(self, options: options)
            self.tableView.cr.resetNoMore()
        }
        
        tableView.cr.footer?.start()
        viewModel.configure(self)
    }
    
    fileprivate func setupAccount() {
        // !!!: ISSUE - AWS 중지
        // if User.shared.isConnected { API.get.certification(self) }
        
        tableView.reloadData()
    }
}

extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        tableView.separatorColor = .clear
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "CommunityHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommunityHeaderView")
        tableView.register(UINib(nibName: "CommunityTableViewCell", bundle: nil), forCellReuseIdentifier: "CommunityTableViewCell")
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.page = 0
            self.viewModel.options.value = FilterOption()
        }
        
        tableView.cr.addFootRefresh() {
            self.page += 1
            self.viewModel.configure(self, page: self.page, options: self.viewModel.options.value)
        }
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommunityHeaderView") as! CommunityHeaderView
        
        header.data = viewModel.options.value ?? FilterOption()
        /* !!!: ISSUE - AWS 중지
        header.addGestureRecognizer { _ in
            self.coordinator?.pushToFilterViewController(animated: true)
        }
        */
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.result.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityTableViewCell", for: indexPath) as! CommunityTableViewCell

        cell.data = viewModel.result.value?[safe: indexPath.row]
        cell.coordinator = self.coordinator
        
        setupButtonAction(tableView, cell: cell, cellForRowAt: indexPath)
        setupButtonMenu(tableView, cell: cell, cellForRowAt: indexPath)
        
        return cell
    }
    
    func setupButtonAction(_ tableView: UITableView, cell: CommunityTableViewCell, cellForRowAt indexPath: IndexPath) {
        /* !!!: ISSUE - AWS 중지
        cell.heartButton.addTarget(self, action: #selector(touchUpInsideForHeart(_:)), for: .touchUpInside)
        cell.bookmarkButton.addTarget(self, action: #selector(touchUpInsideForBookmark(_:)), for: .touchUpInside)
         */
    }
    
    @objc func touchUpInsideForHeart(_ sender: SHToggleButton) {
        guard User.shared.isConnected else {
            Alert.message(self, title: "캐릭터 인증 필요", message: "좋아요를 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                self.coordinator?.pushToRegisterViewController(animated: true)
            }
            return
        }
        
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: position),
              let cell = self.tableView.cellForRow(at: indexPath) as? CommunityTableViewCell,
              let data = viewModel.result.value?[safe: indexPath.row] else { return }
        
        viewModel.result.value?[safe: indexPath.row]?.numberOfLiked = data.isLiked ? data.numberOfLiked - 1 : data.numberOfLiked + 1
        viewModel.result.value?[safe: indexPath.row]?.isLiked = !data.isLiked
        
        API.post.updateLike(type: 0, identifier: data.identifier)
        cell.heartLabel.text = "\(viewModel.result.value?[safe: indexPath.row]?.numberOfLiked ?? 0)"
        
        // Add bound animation
        if data.isLiked {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0, animations: {
                    cell.heartLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                
                }, completion: { _ in
                    UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                        cell.heartLabel.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                    })
                })
            }
        }
    }
    
    @objc func touchUpInsideForBookmark(_ sender: SHToggleButton) {
        guard User.shared.isConnected else {
            Alert.message(self, title: "캐릭터 인증 필요", message: "북마크를 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                self.coordinator?.pushToRegisterViewController(animated: true)
            }
            return
        }
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: position),
              let data = viewModel.result.value?[safe: indexPath.row] else { return }
        
        viewModel.result.value?[safe: indexPath.row]?.isMarked = !data.isMarked
        
        API.post.updateBookmark(post: data.identifier)
    }
    
    func setupButtonMenu(_ tableView: UITableView, cell: CommunityTableViewCell, cellForRowAt indexPath: IndexPath) {
        guard let data = viewModel.result.value?[safe: indexPath.row] else { return }
        let isMine = data.owner == User.shared.identifier && User.shared.isConnected
        
        let delete = UIAction(title: "게시글 삭제", subtitle: nil, image: nil, identifier: nil) { action in
            Alert.message(self, title: "삭제하기", message: "해당 게시글을 삭제할까요?\n삭제된 게시글을 복구가 불가능합니다.", option: .successAndCancelAction) { _ in
                API.post.updatePost(data.identifier, forKey: "DELETE") { result in
                    guard result else { return }
                    self.viewModel.result.value?.remove(at: indexPath.row)
                }
            }
        }
        
        let update = UIAction(title: "게시글 수정", subtitle: nil, image: nil, identifier: nil) { action in
            self.coordinator?.pushToEditPostViewController(data, animated: true)
        }
        
        let report = UIAction(title: "게시글 신고", subtitle: nil, image: nil, identifier: nil) { action in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "신고를 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            self.coordinator?.pushToReportViewController(target: data.identifier, category: 0, user: data.owner, user: data.name, animated: true)
        }
        
        let block = UIAction(title: "작성자 차단", subtitle: nil, image: nil, identifier: nil) { action in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "차단을 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            Alert.message(self, title: "차단하기", message: "해당 글 작성자를 차단할까요?\n차단한 작성자의 글은 보이지 않습니다.", option: .successAndCancelAction) { _ in
                API.post.updateBlock(data.owner) { result in
                    guard result else { return }
                    self.viewModel.result.value?.remove(at: indexPath.row)
                }
            }
        }
        
        let menu = UIMenu(title: "더보기", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: isMine ? [delete, update] : [report, block])
        
        cell.menuButton.menu = menu
        cell.menuButton.showsMenuAsPrimaryAction = true
    }
}
