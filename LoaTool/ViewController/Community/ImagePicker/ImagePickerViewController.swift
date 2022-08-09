//
//  ImagePickerViewController.swift
//  ImagePickerViewControllerSample
//
//  Created by AppDeveloper on 2021/04/12.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

protocol ImagePickerViewDelegate {
    func imagePicker(_ picker: ImagePickerViewController, didFinishPickingAssets assets: [PHAsset])
    func imagePickerDidCancel(_ picker: ImagePickerViewController)
}

extension ImagePickerViewDelegate {
    func imagePickerDidCancel(_ picker: ImagePickerViewController) { picker.dismiss(animated: true, completion: nil) }
}

class ImagePickerViewController: UIViewController, Storyboarded {

    // MARK: IBOutlet
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var albumView: UIView!
    
    // MARK: configure
    let numberOfItemInLine: Int = 4
    let minimumLineSpacing: CGFloat = 1
    var numberOfItemMaxSelection: Int = 20
    let fileMaximumSize: Double = 20        // Mb
    let totalMaximumSize: Double = 40       // 해당 값 변경 시 php.ini 파일 수정해서 업로드 시 문제 발생 없도록 하기
    
    private let imageManager = PHCachingImageManager()
    
    // MARK: var
    var viewModel = ImagePickerViewModel()
    var selectedAssets: [PHAsset] = []
    
    var albums: [Album] = []
    var selectedAlbum: Album?
    
    static var delegate: ImagePickerViewDelegate?
    weak var coordinator: AppCoordinator?

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupCollectionView()
        setupItemViewModelObserver()
        setupNavigationItem()

        requestAuthorization()
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
}

// MARK: - Navigation Bar
extension ImagePickerViewController {
    // MARK:- Navigation
    func setupNavigationItem() {
        // 타이틀 설정
        if let data = albums.first {
            selectedAlbum = data
            
            titleButton.setTitle("\(data.title) ▾", for: .normal)
            titleButton.setTitleColor(.label, for: .normal)

            titleButton.addTarget(self, action: #selector(titleMenuAction(_:)), for: .touchUpInside)
        }
        
        dismissButton.addTarget(self, action: #selector(imagePickerDidCancel), for: .touchUpInside)

        completeButton.isEnabled = self.selectedAssets.count != 0
        completeButton.addTarget(self, action: #selector(didFinishPickingAssets(_:)), for: .touchUpInside)
        
    }
    
    @objc func titleMenuAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.albumView.isHidden = !self.albumView.isHidden
        })
    }
    
    @objc func imagePickerDidCancel() {
        guard let delegate = ImagePickerViewController.delegate else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        delegate.imagePickerDidCancel(self)
    }
    
    @objc func didFinishPickingAssets(_ sender: UIButton) {
        ImagePickerViewController.delegate?.imagePicker(self, didFinishPickingAssets: selectedAssets)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - PHPhotoLibrary
extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    func requestAuthorization() {
        switch PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite) {
        case .authorized:
            viewModel.configure()
            DispatchQueue.main.async {
                self.setupTableView()
            }
        case .limited:
            viewModel.configure()
            DispatchQueue.main.async {
                self.setupTableView()
            }
            
            PHPhotoLibrary.shared().register(self)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { _ in self.requestAuthorization() }
        case .restricted, .denied:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "권한 설정", message: "앨범 접근 권한이 거부되었습니다.\n'설정' 앱에서 권한을 확인해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in self.imagePickerDidCancel() }))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        viewModel.configure()
    }
}



