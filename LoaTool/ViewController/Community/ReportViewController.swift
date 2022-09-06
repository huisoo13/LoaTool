//
//  ReportViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/22.
//

import UIKit

class ReportViewController: UIViewController, Storyboarded {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomAnchor: NSLayoutConstraint!
    
    weak var coordinator: AppCoordinator?
    
    var identifier: String = ""
    var target: String = ""
    var category: Int = 0
    var name: String = ""
    var selectedIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()
        setupHideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setupView() {
        nameLabel.text = name
        
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 0.5
        textView.contentInset = .zero

        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let button = view as? UIButton else { return }
        
            button.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
            button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .selected)
            
            button.tag = i
            button.addTarget(self, action: #selector(touchUpInsideTheButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc func touchUpInsideTheButton(_ sender: UIButton) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true

        stackView.arrangedSubviews.forEach { button in
            guard let button = button as? UIButton else { return }
                
            if sender.tag != button.tag {
                button.isSelected = false
            }
        }
        
        if sender.tag == selectedIndex {
            // 선택한 버튼이 이미 선택 중인 경우
            debug("isSelected")
        } else {
            // 새로운 버튼의 index 저장
            selectedIndex = sender.tag
            sender.isSelected = true
        }
    }
    
    // 키보드 높이 만큼 뷰 올리기
    @objc func keyboardWillShowNotification(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom + keyboardHeight)
        scrollView.setContentOffset(bottomOffset, animated: true)

        bottomAnchor.constant = keyboardHeight
        UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드 높이 만큼 뷰 내리기
    @objc func keyboardWillHideNotification(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
                
        scrollView.setContentOffset(.zero, animated: true)
        bottomAnchor.constant = 0
        UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ReportViewController {
    fileprivate func setupNavigationBar() {
        coordinator?.backgroundColor = .systemBackground
        
        setTitle("신고".localized, size: 20)
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = .systemBlue
        complete.isEnabled = false

        addRightBarButtonItems([complete])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        guard let text = textView.text else { return }
                
        Alert.message(self, title: "신고하기", message: "허위 신고 시\n신고자가 차단 될 수 있습니다.", option: .successAndCancelAction) { _ in
            API.post.insertReport(self, category: self.category, targetIdentifier: self.target, type: self.selectedIndex, user: self.identifier, text: text, completionHandler: { result in
                guard result else { return }
                Alert.message(self, title: "신고 완료", message: "해당 게시글 신고가 완료되었습니다.") { _ in
                    self.coordinator?.popViewController(animated: true)
                }
            })
        }
    }
}
