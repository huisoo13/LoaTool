//
//  Coordinator.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/12/30.
//

/*
 Coordinator Pattern
 
 기존 ViewController에 있는 화면 전환 코드를 한곳에 모아 관리하기 쉽게 만드는 코딩 방식
 */

import UIKit

protocol Coordinator {
    var router: Router? { get }

    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}

class AppCoordinator: Coordinator {
    weak var router: Router?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    

    // MARK: - Configure
    init(router: Router, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.router = router
    }
    
    var tintColor: UIColor? {
        didSet {
            navigationController.navigationBar.tintColor = tintColor ?? .label
        }
    }
    
    var backgroundColor: UIColor? {
        didSet {
            let navigationApperance = UINavigationBarAppearance()
            navigationApperance.configureWithDefaultBackground()
            navigationApperance.backgroundColor = backgroundColor ?? .systemBackground
            navigationApperance.shadowColor = nil
            navigationController.navigationBar.standardAppearance = navigationApperance
            navigationController.navigationBar.compactAppearance = navigationApperance
            navigationController.navigationBar.scrollEdgeAppearance = navigationApperance
        }
    }

    // MARK: - Start
    func start() {
        let viewController = ViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    // MARK: - Push
    func popToRootViewController(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    func pushToViewController(animated: Bool) {
        let viewController = ViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToMainCharacterViewController(animated: Bool) {
        let viewController = MainCharacterViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToCharacterViewController(_ text: String, animated: Bool) {
        let viewController = CharacterViewController.instantiate()
        viewController.coordinator = self
        viewController.text = text
        viewController.isMainCharacter = false
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToTodoConfigureViewController(animated: Bool) {
        let viewController = TodoConfigureViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToTodoManagementViewController(animated: Bool) {
        let viewController = TodoManagementViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToEditCharacterViewController(_ member: Member?, animated: Bool) {
        let viewController = EditCharacterViewController.instantiate()
        viewController.coordinator = self
        viewController.data = member
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToEditContentViewController(_ content: AdditionalContent?, isUpdated: Bool = false, animated: Bool) {
        let viewController = EditContentViewController.instantiate()
        viewController.coordinator = self
        viewController.isUpdated = isUpdated
        viewController.data = content
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToAdvancedContentViewController(_ content: AdditionalContent?, animated: Bool) {
        let viewController = AdvancedContentViewController.instantiate()
        viewController.coordinator = self
        viewController.data = content
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToContentPresetViewController(animated: Bool) {
        let viewController = ContentPresetViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToOpenSourceLibraryViewController(animated: Bool) {
        let viewController = OpenSourceLibraryViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToPostViewController(_ data: Community?, notification: Notification? = nil, animated: Bool) {
        let viewController = PostViewController.instantiate()
        viewController.coordinator = self
        viewController.data = data
        viewController.notification = notification
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToCommentViewController(_ post: Community?, comment: Comment?, notification: Notification? = nil, animated: Bool) {
        let viewController = CommentViewController.instantiate()
        viewController.coordinator = self
        viewController.post = post
        viewController.comment = comment
        viewController.notification = notification
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToFilterViewController(animated: Bool) {
        let viewController = FilterViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToEditPostViewController(_ post: Community? = nil, animated: Bool) {
        let viewController = EditPostViewController.instantiate()
        viewController.coordinator = self
        viewController.community = post
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToNotificationViewController(animated: Bool) {
        let viewController = NotificationViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToRegisterViewController(animated: Bool) {
        let viewController = RegisterViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToReportViewController(target: String, category: Int, user identifier: String, user name: String, animated: Bool) {
        let viewController = ReportViewController.instantiate()
        viewController.coordinator = self
        viewController.identifier = identifier
        viewController.category = category
        viewController.target = target
        viewController.name = name
        
        navigationController.pushViewController(viewController, animated: animated)
    }

    func pushToBlockViewController(animated: Bool) {
        let viewController = BlockViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToOptionViewController(animated: Bool) {
        let viewController = OptionViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToOSTPlayerViewController(animated: Bool) {
        let viewController = OSTPlayerViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToProfitAndLossViewController(animated: Bool) {
        let viewController = ProfitAndLossViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToCalculatorViewController(animated: Bool) {
        let viewController = CalculatorViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToCalculatorACcessoryViewController(_ accessory: Accessory?, animated: Bool) {
        let viewController = CalculatorAccessoryViewController.instantiate()
        viewController.coordinator = self
        viewController.data = accessory
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pushToCalculatorResultViewController(animated: Bool) {
        let viewController = CalculatorResultViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: animated)

    }
    
    /*
     - 일반적인 Push
     let viewController = ViewController.instantiate()
     viewController.coordinator = self
     navigationController.pushViewController(viewController, animated: true)
     */
    
    // MARK: - Pop
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }

    
    // MARK: - Presnet
    func presentToCharacterListViewController(_ delegate: CharacterListDelegate?, list: [String], animated: Bool) {
        let viewController = CharacterListViewController.instantiate()
        
        viewController.coordinator = self
        viewController.delegate = delegate
        viewController.memberList = list
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToTextFieldViewController(_ delegate: TextFieldDelegate?, title: String, allowPickerView: Bool = false, data: [String] = [], usingFilter: Bool = true, keyboardType: UIKeyboardType, animated: Bool) {
        let viewController = TextFieldViewController.instantiate("Popup")
        
        viewController.coordinator = self
        viewController.delegate = delegate
        viewController.text = title
        viewController.keyboardType = keyboardType
        
        viewController.allowPickerView = allowPickerView
        viewController.data = data
        viewController.usingFilter = usingFilter
                
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToJobPickerViewController(_ delegate: JobPickerViewDelegate?, animated: Bool) {
        let viewController = JobPickerViewController.instantiate("Popup")
        
        viewController.coordinator = self
        viewController.delegate = delegate
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToIconPickerViewController(_ delegate: IconPickerViewDelegate?, animated: Bool) {
        let viewController = IconPickerViewController.instantiate("Popup")
        
        viewController.coordinator = self
        viewController.delegate = delegate
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToImagePickerViewController(_ delegate: ImagePickerViewDelegate?, numberOfItemMaxSelection: Int = 20, animated: Bool) {
        let viewController = ImagePickerViewController.instantiate("ImagePicker")
        
        viewController.coordinator = self
        viewController.numberOfItemMaxSelection = numberOfItemMaxSelection

        ImagePickerViewController.delegate = delegate
        
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }

    func presentToBookmarkViewController(_ delegate: BookmarkDelegate?, animated: Bool) {
        let viewController = BookmarkViewController.instantiate()
        
        viewController.coordinator = self
        viewController.delegate = delegate
        
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToImageViewerViewController(_ images: [UIImage]? = nil, imageURL: [String]? = nil, index: Int = 0, animated: Bool) {
        let viewController = ImageViewerViewController.instantiate("Popup")
        
        viewController.coordinator = self
        
        viewController.images = images
        viewController.imageURL = imageURL
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToSpotlightViewController(_ rect: CGRect?, text: String = "", animated: Bool) {
        let viewController = SpotlightViewController.instantiate("Popup")
        
        viewController.coordinator = self
        
        viewController.rect = rect
        viewController.text = text
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        router?.present(viewController, animated: animated)
    }
    
    func presentToOSTViewController(animated: Bool) {
        let viewController = OSTViewController.instantiate()
        viewController.coordinator = self
        
        viewController.modalPresentationStyle = .overCurrentContext

        router?.present(viewController, animated: animated)
    }
    
    func presentToOSTPlayerViewController(animated: Bool) {
        let viewController = OSTPlayerViewController.instantiate()
        viewController.coordinator = self
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext

        router?.present(viewController, animated: animated)
    }
    
    func presentToRecipeViewController(_ recipe: Recipe? = nil, reducedCrafingFeeAtPercent: Double, animated: Bool) {
        let viewController = RecipeViewController.instantiate("Screenshot")
        viewController.coordinator = self
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        viewController.reducedCrafingFeeAtPercent = reducedCrafingFeeAtPercent
        viewController.data = recipe

        router?.present(viewController, animated: animated)
    }
    
    func presentToSummaryViewController(_ data: Character? = nil, _ text: String? = nil, animated: Bool) {
        let viewController = SummaryViewController.instantiate("Screenshot")
        viewController.coordinator = self
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext

        viewController.data = data
        viewController.text = text
        
        router?.present(viewController, animated: animated)
    }
    
    
    // MARK: - Dismiss
    func dismiss(animated: Bool) {
        router?.dismiss(animated: animated)
    }
    
    // MARK: - Remove
    func removeLastDidPush() {
        navigationController.viewControllers.remove(at: navigationController.viewControllers.count - 2)
    }
    
    func removeLastWillPush() {
        navigationController.viewControllers.removeLast()
    }
}
