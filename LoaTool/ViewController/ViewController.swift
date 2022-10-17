//
//  ViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/28.
//

import UIKit

class ViewController: UIViewController, Storyboarded {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var badgeView: UIImageView!
    
    weak var coordinator: AppCoordinator?

    var viewControllers: [UIViewController] = []
    var selectedIndex: Int = UserDefaults.standard.integer(forKey: "didSelectAtIndex")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCoordinator()
        setupViewControllers()
        
        if !UserDefaults.standard.bool(forKey: "22.09.06") {
            UserDefaults.standard.set(false, forKey: "usingCloudKit")
            UserDefaults.standard.set(true, forKey: "22.09.06")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTabBarView()

        NotificationCenter.default.addObserver(self, selector: #selector(showBadge(_:)), name: NSNotification.Name("showBadge"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func showBadge(_ sender: NSNotification) {
        setupTabBarView()
    }
}

// MARK: - Navigation Bar
extension ViewController: CharacterListDelegate {
    fileprivate func setupCoordinator() {
        coordinator?.tintColor = .label
    }
    
    fileprivate func setupTitleForCharacter() {
        setTitle("대표 캐릭터".localized, size: 20)
        
        let list = UIBarButtonItem(image: UIImage(systemName: "list.dash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        
        let mainCharacter = User.shared.name == ""
        addRightBarButtonItems(mainCharacter ? [] : [list])
    }
    
    func character(_ server: String, didSelectRowAt name: String) {
        coordinator?.pushToCharacterViewController(name, animated: true)
    }
    
    fileprivate func setupTitleForSearch() {
        setTitle("전투 정보실".localized, size: 20)
        removeRightBarButtonItem()
    }
    
    fileprivate func setupTitleForTodo() {
        setTitle("할 일".localized, size: 20)
        
        let gear = UIAction(title: "", subtitle: "할 일 관리", image: UIImage(systemName: "gearshape.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), identifier: nil) { _ in
            self.coordinator?.pushToTodoManagementViewController(animated: true)
        }
        
        let option = UIAction(title: "", subtitle: "환경 설정", image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), identifier: nil) { _ in
            self.coordinator?.pushToOptionViewController(animated: true)
        }
        
        let icloud = UIAction(title: "", subtitle: "iCloud 동기화", image: UIImage(systemName: "icloud", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), identifier: nil) { _ in
            let usingCloudKit = UserDefaults.standard.bool(forKey: "usingCloudKit")
            let message = usingCloudKit ? "동기화를 중지해도 기존의 데이터는 남아있습니다.\n\n동기화를 중지하시겠습니까?" : "동일한 iCloud에 로그인 되어있는 기기에서 데이터를 동기화합니다.\n\n해당 기능을 사용 하시겠습니까?"
            Alert.message(self, title: "iCloud 동기화", message: message, option: .successAndCancelAction) { _ in
                UserDefaults.standard.set(!usingCloudKit, forKey: "usingCloudKit")
                
                if !usingCloudKit {
                    CloudManager.shared.commit()
                }
                
                Alert.message(self, title: "설정 완료", message: "앱 재실행 후 적용됩니다.", option: .onlySuccessAction, handler: nil)
            }
        }
        
        let menu = UIMenu(title: "메뉴", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [gear, option, icloud])
        
        let barButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), primaryAction: nil, menu: menu)
        
        let todo = RealmManager.shared.readAll(Todo.self).first == nil
        addRightBarButtonItems(todo ? [] : [barButtonItem])
    }
    
    fileprivate func setupTitleForCommunity() {
        setTitle("커뮤니티".localized, size: 20)

        let showBadge = UserDefaults.standard.bool(forKey: "showBadge")
        
        let symbolConfiguration = showBadge
                    ? UIImage.SymbolConfiguration.preferringMulticolor().applying(UIImage.SymbolConfiguration(paletteColors: [.systemRed, .label])).applying(UIImage.SymbolConfiguration(pointSize: 18, weight: .thin))
                    : UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)
        let image = UIImage(systemName: showBadge ? "bell.badge" : "bell", withConfiguration: symbolConfiguration)
        let bell = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        bell.tag = 0
                
        let edit = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        edit.tag = 1

        addRightBarButtonItems([edit, bell])
    }

    fileprivate func setupTitleForMore() {
        setTitle("더보기".localized, size: 20)
        
        let block = UIAction(title: "", subtitle: "차단 관리", image: nil, identifier: nil) { _ in
            self.coordinator?.pushToBlockViewController(animated: true)
        }
        
        let option = UIAction(title: "", subtitle: "환경 설정", image: nil, identifier: nil) { _ in
            self.coordinator?.pushToOptionViewController(animated: true)
        }

        let menu = UIMenu(title: "관리하기", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [block, option])
        
        let barButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), primaryAction: nil, menu: menu)
        
        addRightBarButtonItems([barButtonItem])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        switch selectedIndex {
        case 0:
            let list = RealmManager.shared.readAll(Character.self).last?.info?.memberList
                .components(separatedBy: " ")
                .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                .filter({ $0 != "" }) ?? []
            
            coordinator?.presentToCharacterListViewController(self, list: list, animated: true)
        case 1:
            break
        case 2:
            break
        case 3:
            if User.shared.isConnected {
                if sender.tag == 0 {
                    coordinator?.pushToNotificationViewController(animated: true)
                } else {
                    coordinator?.pushToEditPostViewController(animated: true)
                }
            } else {
                Alert.message(self, title: "캐릭터 인증 필요", message: "포스트를 작성 및 알림을 확인하기 위해서는\n대표 캐릭터 인증을 해야합니다.") { _ in
                    self.coordinator?.pushToRegisterViewController(animated: true)
                }
            }
        case 4:
            debug(selectedIndex)
        default:
            break
        }
    }
}


// MARK: - Tab Bar
extension ViewController {
    fileprivate func setupViewControllers() {
        viewControllers.append {
            let viewController = CharacterViewController.instantiate()
            viewController.coordinator = self.coordinator
            
            return viewController
        }
        
        viewControllers.append {
            let viewController = SearchViewController.instantiate()
            viewController.coordinator = self.coordinator
            
            return viewController
        }
        
        viewControllers.append {
            let viewController = TodoViewController.instantiate()
            viewController.coordinator = self.coordinator
            
            return viewController
        }
        
        viewControllers.append {
            let viewController = CommunityViewController.instantiate()
            viewController.coordinator = self.coordinator
            
            return viewController
        }
        
        viewControllers.append {
            let viewController = MoreViewController.instantiate()
            viewController.coordinator = self.coordinator
            
            return viewController
        }
    }
    
    fileprivate func setupTabBarView() {        
        let showBadge = UserDefaults.standard.bool(forKey: "showBadge")
        badgeView.isHidden = !showBadge
        
        stackView.arrangedSubviews.enumerated().forEach { i, button in
            guard let button = button as? UIButton else { return }
            
            button.tag = i
            button.addTarget(self, action: #selector(touchUpInsideTheButton(_:)), for: .touchUpInside)
            
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .label
            configuration.imagePlacement = .top
            configuration.imagePadding = 5
            configuration.buttonSize = .mini
            
            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 10)

            switch button.tag {
            case 0:
                configuration.attributedTitle = AttributedString("대표 캐릭터".localized, attributes: container)

                button.setImage(UIImage(systemName: "person.text.rectangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
                button.setImage(UIImage(systemName: "person.text.rectangle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .selected)
            case 1:
                configuration.attributedTitle = AttributedString("전투 정보실".localized, attributes: container)

                button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
                button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .selected)
            case 2:
                configuration.attributedTitle = AttributedString("할 일".localized, attributes: container)

                button.setImage(UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
                button.setImage(UIImage(systemName: "clock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .selected)
            case 3:
                configuration.attributedTitle = AttributedString("커뮤니티".localized, attributes: container)

                button.setImage(UIImage(systemName: "person.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
                button.setImage(UIImage(systemName: "person.3.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .selected)
            case 4:
                configuration.attributedTitle = AttributedString("더보기".localized, attributes: container)

                button.setImage(UIImage(systemName: "ellipsis.bubble", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .normal)
                button.setImage(UIImage(systemName: "ellipsis.bubble.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)), for: .selected)
            default:
                break
            }
            
            button.configuration = configuration
            
            if i == self.selectedIndex { touchUpInsideTheButton(button) }
        }
    }
    
    
    // 최초 viewDidLoad 에서 한번 함수를 실행시키기
    @objc func touchUpInsideTheButton(_ sender: UIButton) {
        // 선택한 버튼을 제외하고 모든 버튼 선택 취소
        stackView.arrangedSubviews.forEach { button in
            guard let button = button as? UIButton else { return }
                
            if sender.tag != button.tag {
                button.isSelected = false
            }
            
            button.alpha = 0.5
        }
        
        if sender.isSelected {
            // 선택한 버튼이 이미 선택 중인 경우
            // debug("Now view")
        } else {
            // 새로운 버튼을 선택한 경우
            // 이전에 선택되어 있던 버튼의 index 저장
            let previousIndex = self.selectedIndex
            
            // 새로운 버튼의 index 저장
            self.selectedIndex = sender.tag
            
            // 앱을 새로 실행 했을때 종료 전 선택했던 index 를 알 수 있도록 저장
            // 카카오톡처럼 실행시 그전 탭 불러오는 경우 이용 가능
            UserDefaults.standard.set(sender.tag, forKey: "didSelectAtIndex")
                            
            // viewControllers: 탭바의 눌렀을때 보여줄 viewController의 Array
            let previous = viewControllers[previousIndex]
            
            // 이전의 viewController를 해제
            previous.willMove(toParent: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParent()
            
            // 선택한 버튼의 선택 여부 true
            sender.isSelected = true

            // 새로 선택한 버튼에 해당하는 viewController 할당
            let viewController = viewControllers[self.selectedIndex]
            addChild(viewController)
            
            // contentView에 viewController 추가
            viewController.view.frame = contentView.bounds
            contentView.addSubview(viewController.view)
            
            // 이동
            viewController.didMove(toParent: self)
        }
      
        // 어느 버튼을 눌렀느냐에 따라 탭바의 변경사항을 적용
        switch sender.tag {
        case 0:
            setupTitleForCharacter()
        case 1:
            setupTitleForSearch()
        case 2:
            setupTitleForTodo()
        case 3:
            setupTitleForCommunity()
        case 4:
            setupTitleForMore()
        default:
            break
        }
        
        sender.alpha = 1
        
        // 선택 애니메이션 추가
        selectedAnimation(sender)
    }
    
    func selectedAnimation(_ sender: UIButton) {
        let imageView = UIImageView(image: UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .ultraLight)))
        imageView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        imageView.tintColor = .label
        imageView.center = stackView.arrangedSubviews[0].center
        imageView.alpha = 0.75
        
        sender.addSubview(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                imageView.alpha = 0
            }, completion: { _ in
                imageView.removeFromSuperview()
            })
        })
    }
}

extension ViewController: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if (navigationController.viewControllers.count > 1) {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
