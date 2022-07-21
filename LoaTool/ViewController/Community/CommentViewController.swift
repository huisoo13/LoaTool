//
//  CommentViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/21.
//

import UIKit

class CommentViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var mentionView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var bottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    
    weak var coordinator: AppCoordinator?
    
    var post: Community?
    var comment: Comment?
    var viewModel = CommentViewModel()

    var notification: Notification?

    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupHideKeyboardOnTap()
        setupNavigationBar()
        setupTableView()
        setupTextView()
        setupGestureRecognizer()
        setupViewModelObserver()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        textView.becomeFirstResponder()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupTextView()
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            guard let _ = result else { return }

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
        
        guard let data = self.comment else { return }
        viewModel.configure(self, type: 1, identifier: data.identifier, page: 0)
    }
    
    func setupNotification() {
        guard let data = notification, data.reply != "" else { return }
        API.get.selectSingleComment(self, type: 1, identifier: data.reply) { comment in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            cell.data = comment
            cell.commentView.isHidden = true

            self.stackView.backgroundColor = .secondarySystemGroupedBackground
            self.stackView.insertArrangedSubview(cell.contentView, at: 0)
            self.stackView.arrangedSubviews.forEach {
                $0.sizeToFit()
                $0.layoutIfNeeded()
            }
        }
    }
    
    func setupGestureRecognizer() {
        button.addGestureRecognizer { _ in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "댓글을 달기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            guard let post = self.post,
                  let data = self.comment,
                  let text = self.textView.text, text != "" else {
                return
            }

            self.button.isEnabled = false
            API.post.insertComment(self, type: 1, post: post.identifier, mention: data.identifier, input: text) { result in
                self.textView.text = ""
                self.textViewDidChange(self.textView)
                
                self.textView.endEditing(true)
                self.viewModel.configure(self, type: 1, identifier: data.identifier, page: 0)
                self.tableView.setContentOffset(.zero, animated: true)
                self.button.isEnabled = true
            }
        }
    }

    // 키보드 높이 만큼 뷰 올리기
    @objc func keyboardWillShowNotification(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first { $0.isKeyWindow }
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        bottomAnchor.constant = keyboardHeight - bottomPadding
        UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드 높이 만큼 뷰 내리기
    @objc func keyboardWillHideNotification(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
                
        self.bottomAnchor.constant = 0
        UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}

extension CommentViewController {
    fileprivate func setupNavigationBar() {
        setTitle("댓글".localized, size: 20)
        addRightBarButtonItems([])
    }

}

extension CommentViewController: UITextViewDelegate {
    func setupTextView() {
        textView.delegate = self
        
        textView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)

        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 0.5
        
        button.setImage(UIImage(systemName: "bubble.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), for: .normal)
        

    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard var text = textView.text else { return }
        
        let originHeight: CGFloat = 50
        let lineHeight = (textView.font ?? UIFont.systemFont(ofSize: 14)).lineHeight
        let numberOfLines = round((textView.contentSize.height) / lineHeight) - 1
        
        heightAnchor.constant = numberOfLines < 6
        ? originHeight + (lineHeight * CGFloat(numberOfLines - 1))
        : originHeight + (lineHeight * CGFloat(4))
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in }
        
        if numberOfLines > 30 { text.removeLast() }
        
        let image = text == ""
        ? UIImage(systemName: "bubble.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin))
        : UIImage(systemName: "plus.bubble.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))
        button.setImage(image, for: .normal)
        button.tintColor = text == "" ? .label : .custom.textBlue
        
        textView.attributedText = text.attributed(of: text, key: .foregroundColor, value: UIColor.label)
            .addAttribute(using: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", key: .foregroundColor, value: UIColor.custom.qualityBlue)
            .addAttribute(using: "(^|[\\s.:;?\\-\\]<\\(])" +
                          "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
                          "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])", key: .foregroundColor, value: UIColor.systemBlue)

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

    }

}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear

        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        guard let data = self.comment else { return }

        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.page = 0
            
            self.viewModel.configure(self, type: 1, identifier: data.identifier, page: self.page)
            self.tableView.cr.resetNoMore()
        }
        
        tableView.cr.addFootRefresh() {
            self.page += 1
            
            self.viewModel.configure(self, type: 1, identifier: data.identifier, page: self.page)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.result.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = viewModel.result.value?[safe: indexPath.row]
        
        if data?.identifier == notification?.reply && notification != nil {
            stackView.arrangedSubviews.first?.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        let data: Comment? = indexPath.section == 0 ? comment : viewModel.result.value?[safe: indexPath.row]
        
        cell.isOwner = self.post?.owner == data?.owner
        cell.data = data
        cell.coordinator = coordinator
        cell.commentView.isHidden = true
        
        setupGestureRecognizer(tableView, cell: cell, cellForRowAt: indexPath)

        return cell
    }
    
    func setupGestureRecognizer(_ tableView: UITableView, cell: CommentTableViewCell, cellForRowAt indexPath: IndexPath) {
        guard let data = indexPath.section == 0 ? comment : self.viewModel.result.value?[safe: indexPath.row] else {
            return
        }
        
        cell.heartView.addGestureRecognizer { _ in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "좋아요를 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            if indexPath.section == 0 {
                self.comment?.numberOfLiked = data.isLiked ? data.numberOfLiked - 1 : data.numberOfLiked + 1
                self.comment?.isLiked = !data.isLiked
            } else {
                self.viewModel.result.value?[safe: indexPath.row]?.numberOfLiked = data.isLiked ? data.numberOfLiked - 1 : data.numberOfLiked + 1
                self.viewModel.result.value?[safe: indexPath.row]?.isLiked = !data.isLiked
            }
            
            API.post.updateLike(type: indexPath.section == 0 ? 1 : 2, identifier: data.identifier)
            cell.data = indexPath.section == 0 ? self.comment : self.viewModel.result.value?[safe: indexPath.row]

            if data.isLiked {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0, animations: {
                        cell.heartView.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                    
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            cell.heartView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                        })
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let data = viewModel.result.value?[safe: indexPath.row] else { return nil }
        let isMine = data.owner == User.shared.identifier && User.shared.isConnected

        let delete = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            Alert.message(self, title: "삭제하기", message: "해당 댓글을 삭제할까요?\n삭제된 댓글은 복구가 불가능합니다.", option: .successAndCancelAction) { _ in
                API.post.updateComment(data.identifier, type: 1) { result in
                    guard result else { return }
                    self.viewModel.result.value?.remove(at: indexPath.row)
                }
            }

            
            completionHandler(true)
        }
        
        delete.backgroundColor = .custom.qualityRed
        delete.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin))?.withTintColor(.systemGray6).withRenderingMode(.alwaysOriginal)
        
        let report = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "신고를 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            self.coordinator?.pushToReportViewController(target: data.identifier, category: 2, user: data.owner, user: data.name, animated: true)
            completionHandler(true)
        }
        
        report.backgroundColor = .systemGray
        report.image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin))?.withTintColor(.systemGray6).withRenderingMode(.alwaysOriginal)

        let block = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            guard User.shared.isConnected else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "차단을 하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
                return
            }
            
            Alert.message(self, title: "차단하기", message: "해당 댓글 작성자를 차단할까요?\n차단한 작성자의 글은 보이지 않습니다.", option: .successAndCancelAction) { _ in
                API.post.updateBlock(data.owner) { result in
                    guard result else { return }
                    self.viewModel.result.value?.remove(at: indexPath.row)
                }
            }
            
            completionHandler(true)
        }
        
        block.backgroundColor = .separator
        block.image = UIImage(systemName: "speaker.slash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin))?.withTintColor(.systemGray6).withRenderingMode(.alwaysOriginal)

        
        let swipeAction = UISwipeActionsConfiguration(actions: isMine ? [delete] : [block, report])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return indexPath.section == 0 ? nil : swipeAction
    }
}
