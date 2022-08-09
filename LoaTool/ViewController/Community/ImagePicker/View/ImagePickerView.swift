//
//  ImagePickerView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/08/05.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

class ImagePickerView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: configure
    let numberOfItemInLine: Int = 4
    let minimumLineSpacing: CGFloat = 1
    let numberOfItemMaxSelection: Int = 1
    let fileMaximumSize: Double = 20        // Mb
    let totalMaximumSize: Double = 40       // 해당 값 변경 시 php.ini 파일 수정해서 업로드 시 문제 발생 없도록 하기
    
    private let imageManager = PHCachingImageManager()
    
    // MARK: var
    var viewModel = ImagePickerViewModel()
    var selectedAsset: PHAsset?
    
    var delegate: ImagePickerViewDelegate?
    
    weak var coordinator: AppCoordinator?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadView()
        setupCollectionView()
        setupItemViewModelObserver()
        requestAuthorization()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadView()
        setupCollectionView()
        setupItemViewModelObserver()
        requestAuthorization()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("ImagePickerView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)

    }
    
    // MARK: Binding
    fileprivate func setupItemViewModelObserver() {
        viewModel.result.bind { result in
            guard let _ = result else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    @IBAction func presentToImagePickerViewController(_ sender: UIButton) {
        self.parentViewController?.view.endEditing(true)
        coordinator?.presentToImagePickerViewController(delegate, numberOfItemMaxSelection: 1, animated: true)
    }
}

// MARK: - PHPhotoLibrary
extension ImagePickerView: PHPhotoLibraryChangeObserver {
    func requestAuthorization() {
        switch PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite) {
        case .authorized:
            viewModel.configure()

        case .limited:
            viewModel.configure()

            PHPhotoLibrary.shared().register(self)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { _ in self.requestAuthorization() }
        case .restricted, .denied:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "권한 설정", message: "앨범 접근 권한이 거부되었습니다.\n'설정' 앱에서 권한을 확인해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in self.delegate?.imagePickerDidCancel(ImagePickerViewController()) }))
                self.parentViewController?.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        viewModel.configure()
    }
}


extension ImagePickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(UINib(nibName: "ImagePickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagePickerCollectionViewCell")
    }

    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.result.value?.assets.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView(collectionView, didSelectedAndDeselectedItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionView(collectionView, didSelectedAndDeselectedItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectedAndDeselectedItemAt indexPath: IndexPath) {
        guard let asset = viewModel.result.value?.assets[indexPath.item],
              let viewController = self.parentViewController else { return }
        
        // 선택한 파일 사이즈 확인
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            let sizeOnDisk: Int64  = Int64(bitPattern: UInt64(unsignedInt64!))
            
            let size = Double(sizeOnDisk) / (1024.0 * 1024.0)
            if fileMaximumSize <= size {
                Alert.message(viewController, title: "이미지 크기 제한", message: "이미지 크기는 \(fileMaximumSize)Mb를 넘을 수 없습니다.", handler: nil)
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
        }

        selectedAsset = asset
        delegate?.imagePicker(ImagePickerViewController(), didFinishPickingAssets: [asset])
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            let storyboard = UIStoryboard(name: "ImagePicker", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContentPreviewViewController") as! ContentPreviewViewController

            viewController.asset = self.viewModel.result.value?.assets[indexPath.item]

            return viewController
        }, actionProvider: nil)

        return configuration
    }


    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .dismiss

        /*
        if let indexPath = configuration.identifier as? IndexPath {
            animator.addCompletion {
                let storyboard = UIStoryboard(name: "ImagePicker", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController

                viewController.assets = self.assets
                viewController.indexPath = IndexPath(item: indexPath.item - self.showCameraButtonIndex, section: indexPath.section)

                self.present(viewController, animated: true, completion: nil)
            }
        }
        */
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCollectionViewCell", for: indexPath) as? ImagePickerCollectionViewCell,
              let asset = viewModel.result.value?.assets[indexPath.item] else { return UICollectionViewCell() }
                
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.asset = asset
        cell.selectedNumber = nil

        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.height
        let cellSize = CGSize(width: cellWidth - 48, height: cellWidth - 16)
        
        return cellSize
    }

    
    
}


extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
