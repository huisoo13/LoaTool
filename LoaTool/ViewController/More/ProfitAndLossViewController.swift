//
//  ProfitAndLossViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/13.
//

import UIKit

class ProfitAndLossViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var removeButton: UIButton!
    
    weak var coordinator: AppCoordinator?

    var viewModel: RecipeViewModel = RecipeViewModel()
    var reducedCrafingFeeAtPercent: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHideKeyboardOnTap()
        setupNavigationBar()
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
    
    fileprivate func setupViewModelObserver() {
        viewModel.filter.bind { data in
            guard let data = data,
                  data.count != 0 else { return }
            
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.removeFooter()
            
            self.tableView.reloadData()
        }
        
        viewModel.configure(self)
    }
}

extension ProfitAndLossViewController {
    fileprivate func setupNavigationBar() {
        setTitle("제작 공방".localized, size: 20)
        
        reducedCrafingFeeAtPercent = UserDefaults.standard.double(forKey: "reducedCrafingFeeAtPercent")
        
        let title = String(format: "제작 수수료 감소 %.1f", reducedCrafingFeeAtPercent * 100) + "%"
        let reduce = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(touchUpInside(_:)))
        reduce.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .light)], for: .normal)
        reduce.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .light)], for: .selected)
        addRightBarButtonItems([reduce])
    }
    
    @objc func touchUpInside(_ sender: UIBarButtonItem) {
        coordinator?.presentToTextFieldViewController(self, title: "제작 수수료 감소", keyboardType: .decimalPad, animated: true)
    }
}

extension ProfitAndLossViewController: UITextFieldDelegate, TextFieldDelegate {
    func setupTextField() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        removeButton.addGestureRecognizer { _ in
            self.textField.text = ""
            self.removeButton.isHidden = true
            self.removeButton.isEnabled = false
            
            self.viewModel.filter(contains: "")
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        removeButton.isHidden = text == ""
        removeButton.isEnabled = !(text == "")
        
        viewModel.filter(contains: text)
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
    
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        reducedCrafingFeeAtPercent = (Double(text) ?? 0.0) / 100
        UserDefaults.standard.set(reducedCrafingFeeAtPercent, forKey: "reducedCrafingFeeAtPercent")
        
        let title = String(format: "제작 수수료 감소 %.1f%", reducedCrafingFeeAtPercent * 100) + "%"
        let reduce = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(touchUpInside(_:)))
        reduce.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .light)], for: .normal)
        reduce.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .light)], for: .selected)
        addRightBarButtonItems([reduce])
        
        tableView.reloadData()
    }
}

extension ProfitAndLossViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .onDrag

        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "ProfitAndLossTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfitAndLossTableViewCell")
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.viewModel.configure(self)
        }
        
        tableView.cr.addFootRefresh() { }
        
        tableView.cr.footer?.start()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let data = viewModel.filter.value else { return 0 }
        
        let set = Set(data.map { $0.category })
        let array = Array(set)

        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        if let data = viewModel.filter.value {
            let set = Set(data.map { $0.category })
            let array = Array(set).sorted(by: { $0 < $1 })

            header.label.text = array[section]
        }
        
        header.typeView.isHidden = true
        header.button.isHidden = true

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = viewModel.filter.value else { return 0 }
        
        let set = Set(data.map { $0.category })
        let array = Array(set).sorted(by: { $0 < $1 })

        let filter = data.filter { $0.category == array[section] }
        
        return filter.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfitAndLossTableViewCell", for: indexPath) as! ProfitAndLossTableViewCell
        
        if let data = viewModel.filter.value {
            let set = Set(data.map { $0.category })
            let array = Array(set).sorted(by: { $0 < $1 })

            let filter = data.filter { $0.category == array[indexPath.section] }
            
            cell.reducedCrafingFeeAtPercent = reducedCrafingFeeAtPercent
            cell.data = filter[safe: indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.filter.value else { return }
        
        let set = Set(data.map { $0.category })
        let array = Array(set).sorted(by: { $0 < $1 })

        let filter = data.filter { $0.category == array[indexPath.section] }

        coordinator?.presentToRecipeViewController(filter[safe: indexPath.row], reducedCrafingFeeAtPercent: reducedCrafingFeeAtPercent, animated: true)
    }
}

