//
//  EditPostViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/28.
//

import UIKit
import Photos

class EditPostViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var bookmarkLabel: UILabel!
    
    weak var coordinator: AppCoordinator?
    
    var image: [Image] = []
    var gateway: String = ""
    
    var community: Community?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupNavigationBar()
        setupView()
        setupGestureRecognizer()
        setupTextView()
        setupHideKeyboardOnTap()
        setupData()

        DispatchQueue.global(qos: .background).async {
            CharacterViewModel().configure(self, search: User.shared.name, isMain: true, showIndicator: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func setupView() {
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 0.5

        imageView.layer.cornerRadius = 2
        imageLabel.text = "선택한 사진이 없습니다."
        bookmarkLabel.text = "선택한 북마크가 없습니다."
    }
    
    func setupData() {
        guard let community = community else {
            return
        }

        textView.text = community.text
        imageLabel.text = "사진은 변경할 수 없습니다."
        bookmarkLabel.text = "북마크는 변경할 수 없습니다."
        
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            view.isUserInteractionEnabled = false
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = community.text != ""
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            switch i {
            case 0:
                view.addGestureRecognizer { _ in
                    self.coordinator?.presentToImagePickerViewController(self, animated: true)
                }
            case 1:
                view.addGestureRecognizer { _ in
                    self.coordinator?.presentToBookmarkViewController(self, animated: true)
                }
            default:
                break
            }
        }
    }
}


extension EditPostViewController {
    fileprivate func setupNavigationBar() {
        setTitle("새 게시글".localized, size: 20, backButtonHandler: {
            self.didRemovePostWarning()
        })
        
        coordinator?.backgroundColor = .systemBackground
        
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        complete.tintColor = .systemBlue
        complete.isEnabled = false

        addRightBarButtonItems([complete])
    }
    
    func didRemovePostWarning() {
        let alert = UIAlertController(title: nil, message: "작성한 내용 및 사진이 초기화됩니다.", preferredStyle: .actionSheet)
        alert.pruneNegativeWidthConstraints()

        let resetAction = UIAlertAction(title: "초기화", style: .destructive, handler: { _ in
            self.coordinator?.popViewController(animated: true)
        })

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { _ in })

        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = self.navigationItem.leftBarButtonItem
        }

        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        guard let text = textView.text else { return }

        let title = community == nil ? "새 게시글을 작성 중입니다." : "게시글을 수정 중입니다."
        IndicatorView.showLoadingView(self, title: title)
        
        if let community = self.community {
            API.post.updatePost(community.identifier, text: text, forKey: "UPDATE") { _ in
                CommunityViewController.reloadToData = true
                CommunityViewController.options = FilterOption()

                IndicatorView.hideLoadingView()
                self.coordinator?.popViewController(animated: true)
            }
        } else {
            API.post.uploadImageForPost(self, input: text, input: self.image, gateway: self.gateway) { _ in
                CommunityViewController.reloadToData = true
                CommunityViewController.options = FilterOption()

                IndicatorView.hideLoadingView()
                self.coordinator?.popViewController(animated: true)
            }
        }
    }
}

extension EditPostViewController: UITextViewDelegate {
    func setupTextView() {
        textView.delegate = self
        textView.contentInset = .zero
        
        textView.becomeFirstResponder()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        self.navigationItem.rightBarButtonItem?.isEnabled = text != ""

        // 문제: text 또는 attributedText를 설정하면 Curser position이 가장 마지막으로 변경되기 떄문에 변경 전에 미리 값을 저장 후 다시 불러와야한다.
        // STEP 1: 위치값 저장
        guard let selectedTextRange = textView.selectedTextRange else { return }
        
        // STEP 2: 코드 실행 후 위치값 변경
        textView.attributedText = text.attributed(of: text, key: .foregroundColor, value: UIColor.label)
            .addAttribute(using: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", key: .foregroundColor, value: UIColor.custom.qualityBlue)
            .addAttribute(using: "(^|[\\s.:;?\\-\\]<\\(])" +
                          "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
                          "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])", key: .foregroundColor, value: UIColor.systemBlue)
            .addAttribute(using: gateway != "" ? "\\b북마크\\b" : "\\b", key: .foregroundColor, value: UIColor.custom.qualityOrange)
        
        // STEP 3: 저장한 위치값 불러오기
        if let selectedTextRange = textView.position(from: selectedTextRange.start, offset: 0) {
            textView.selectedTextRange = textView.textRange(from: selectedTextRange, to: selectedTextRange)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

    }
}

extension EditPostViewController: ImagePickerViewDelegate {
    func imagePicker(_ picker: ImagePickerViewController, didFinishPickingAssets assets: [PHAsset]) {
        let uuid = UUID().uuidString
        let stove = User.shared.stove
        image = assets.enumerated().map({ i, asset in
            guard let origin = ImageManager.shared.requestImage(for: asset, isThumbnail: false) else { return Image() }
            return Image(fileName: "\(stove)-\(uuid)-\(String(format: "%02d", i))", image: origin)
        })
        
        guard let asset = assets.first else { return }
        
        let image = ImageManager.shared.requestImage(for: asset, isThumbnail: true)
        imageView.image = image
        imageLabel.text = "외 \(assets.count - 1)장을 선택했습니다."
        imageLabel.isHidden = assets.count < 2
    }
}

extension EditPostViewController: BookmarkDelegate {
    func bookmark(_ viewController: UIViewController, didSelectItem item: Community) {
        gateway = item.identifier
        bookmarkLabel.attributedText = "\(item.name)님의 게시글을 선택했습니다.".attributed(of: item.name, key: .foregroundColor, value: UIColor.label)
        
        if !textView.text.contains("북마크") { textView.text += " 북마크" }
        
        textViewDidChange(textView)
    }
}
