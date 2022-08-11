//
//  MainCharacterViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/07.
//

import UIKit
import Kingfisher

class MainCharacterViewController: UIViewController, Storyboarded {
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var coordinator: AppCoordinator?
    
    var text: String = ""
    var data: Character? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupNavigationBar()
        setupView()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        
    }
    
    func setupView() {
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor
        jobView.layer.cornerRadius = 6
        
        stackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.systemGray4.cgColor
            view.layer.cornerRadius = 6
        }
        
        if data == nil { return }
        imageView.image = data?.info?.job.getSymbol()
        imageView.tintColor = .label
        
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }
            
            switch i {
            case 0:
                textField.text = data?.info?.name.components(separatedBy: " ")[safe: 1]
            case 1:
                textField.text = String(data?.info?.level ?? 0)
            default:
                break
            }
        }
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let textField = view.subviews[safe: 1] as? UITextField else { return }
            textField.isUserInteractionEnabled = false
            
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.coordinator?.presentToTextFieldViewController(self, title: "이름", keyboardType: .default, animated: true)
                }
            case 1:
                break
            default:
                break
            }
        }
    }
    
    func parsingUserData() {
        if text == "" { return }

        IndicatorView.showLoadingView()
        Parsing.shared.downloadHTML(text, type: [.stats, .equip, .engrave, .gem, .card]) { data, error in
            self.data = data
            
            switch error {
            case .notFound:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "캐릭터명을 다시 확인해주세요.").present()
            case .websiteInspect:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "로스트아크 공식 홈페이지가 점검 중입니다.").present()
            case .unknown:
                Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "알 수 없는 오류가 발생했습니다.").present()
            case nil:
                break
            }

            IndicatorView.hideLoadingView()
            self.setupNavigationBar()
            self.setupView()
        }
    }
}

extension MainCharacterViewController {
    fileprivate func setupNavigationBar() {
        setTitle("대표 캐릭터 설정".localized, size: 20)
        
        let reset = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        reset.tintColor = .systemBlue
        reset.isEnabled = data != nil
        
        addRightBarButtonItems([reset])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "설정", message: "\n해당 캐릭터로 설정을 할까요?\n이후에 다시 설정 가능합니다.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "설정", style: .default) { _ in
            guard let data = self.data else { return }
            
            CharacterViewModel().updateWithRealm(data)
            self.coordinator?.popViewController(animated: true)
        }
        
        let no = UIAlertAction(title: "취소", style: .destructive) { _ in }
        
        alert.addAction(no)
        alert.addAction(ok)

        self.present(alert, animated: true)
    }
}

extension MainCharacterViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.text = text
        parsingUserData()
    }
}

