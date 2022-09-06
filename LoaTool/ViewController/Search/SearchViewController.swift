//
//  SearchViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

class SearchViewController: UIViewController, Storyboarded {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    let viewModel = SearchViewModel()
    var text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHideKeyboardOnTap()
        setupTableView()
        setupTextField()
        setupViewModelObserver()
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
    
    
    @IBAction func searchAction(_ sender: UIButton) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              text != "" else { return }
        
        self.text = text
        viewModel.configure(search: text)
        
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            self.tableView.reloadData()
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
        
        bottomAnchor.constant = keyboardHeight - bottomPadding - 50
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

extension SearchViewController: UITextFieldDelegate {
    func setupTextField() {
        textField.delegate = self
        textField.returnKeyType = .search
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction(button)
        
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        tableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
        tableView.register(UINib(nibName: "ErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "ErrorTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = viewModel.result.value != nil || viewModel.error != nil
        ? DateManager.shared.convertDateFormat(DateManager.shared.currentDate(), originFormat: "yyyy-MM-dd HH:mm:ss", newFormat: "a hh:mm")
        : "캐릭터를 검색하여 능력치 및 전투스킬을 확인 할 수 있습니다."
    
        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.result.value != nil || viewModel.error != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let error = viewModel.error else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as! InfoTableViewCell
            
            cell.data = viewModel.result.value
            cell.addGestureRecognizer { _ in
                self.coordinator?.pushToCharacterViewController(self.text, animated: true)
            }
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorTableViewCell", for: indexPath) as! ErrorTableViewCell

        cell.error = error

        return cell
    }
}
