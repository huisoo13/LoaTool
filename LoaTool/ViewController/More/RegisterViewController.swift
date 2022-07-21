//
//  RegisterViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/10.
//

import UIKit

class RegisterViewController: UIViewController, Storyboarded {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var textField: UITextField!
        
    weak var coordinator: AppCoordinator?
    
    var viewModel: RegisterViewModel = RegisterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")
        
        setupNavigationBar()
        setupHideKeyboardOnTap()
        setupViewModelObserver()
        setupView()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
    }
    
    fileprivate func setupView() {
        codeLabel.text = UUID().uuidString
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            guard let name = result, name != "",
                  let stove = self.textField.text else { return }
                        
            API.post.insertCertifiedUser(self, stove: stove, character: name) { result in
                if result {
                    CommunityViewController.reloadToData = true
                    self.coordinator?.popViewController(animated: true)
                }
            }
        }
    }
    
    func setupGestureRecognizer() {
        copyButton.addGestureRecognizer { _ in
            UIPasteboard.general.string = self.codeLabel.text
            Alert.message(self, title: "", message: "복사 완료", option: .onlySuccessAction, handler: nil)
        }
    }
}

extension RegisterViewController {
    fileprivate func setupNavigationBar() {
        setTitle("본인 인증".localized, size: 20)
        
        coordinator?.backgroundColor = .systemBackground
        
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = .systemBlue
        complete.isEnabled = false

        addRightBarButtonItems([complete])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        guard let text = textField.text,
              let authenticationCode = codeLabel.text else { return }

        viewModel.register(self, stove: text, authentication: authenticationCode)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    @objc func editingChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.navigationItem.rightBarButtonItem?.isEnabled = text != ""
    }
}
