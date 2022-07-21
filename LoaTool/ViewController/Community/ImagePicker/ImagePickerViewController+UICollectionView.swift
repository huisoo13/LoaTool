//
//  ImagePickerViewController+UICollectionView.swift
//  ImagePickerViewControllerSample
//
//  Created by Trading Taijoo on 2022/04/26.
//

import UIKit
import Photos

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(UINib(nibName: "ImagePickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagePickerCollectionViewCell")
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.result.value?.assets.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = viewModel.result.value?.assets[indexPath.item],
              let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else { return }

    
        // 선택한 파일 사이즈 확인
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            let sizeOnDisk: Int64  = Int64(bitPattern: UInt64(unsignedInt64!))
            
            let size = Double(sizeOnDisk) / (1024.0 * 1024.0)
            if fileMaximumSize <= size {
                Alert.message(self, title: "이미지 크기 제한", message: "이미지 크기는 \(fileMaximumSize)Mb를 넘을 수 없습니다.", handler: nil)
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
            
            // 선택했던 파일 사이즈 확인
            let totalSizeOfSelectedAssets: [Double] = selectedAssets.map { asset in
                let resources = PHAssetResource.assetResources(for: asset)
                
                guard let resource = resources.first else { return 0 }
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                let sizeOnDisk: Int64 = Int64(bitPattern: UInt64(unsignedInt64!))
                
                let size = Double(sizeOnDisk) / (1024.0 * 1024.0)
                return size
            }

            // 총합 확인
            if totalMaximumSize <= (totalSizeOfSelectedAssets.reduce(0, +) + size) {
                Alert.message(self, title: "이미지 크기 제한", message: "선택한 모든 이미지 크기의 합은 \(totalMaximumSize)Mb를 넘을 수 없습니다.", handler: nil)
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
        }
        
        if numberOfItemMaxSelection <= selectedAssets.count {
            Alert.message(self, title: "제한", message: "최대 \(numberOfItemMaxSelection)개의 이미지까지 선택 할 수 있습니다.", handler: nil)
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectedAssets = !selectedAssets.contains(asset) ? selectedAssets + [asset] : selectedAssets.filter { $0 != asset }

        cell.selectedNumber = selectedAssets.firstIndex(where: { $0 == asset })
        completeButton.isEnabled = self.selectedAssets.count != 0
        
        // 카메라 추가의 잔재
//        viewModel.result.value?.assets.insert(asset, at: 1)
//        collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let asset = viewModel.result.value?.assets[safe: indexPath.item],
              let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else { return }
        
        selectedAssets = selectedAssets.filter { $0 != asset }
        completeButton.isEnabled = self.selectedAssets.count != 0

        cell.selectedNumber = selectedAssets.firstIndex(where: { $0 == asset })
        
        // 선택한 셀 번호 갱신
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        indexPaths.forEach { indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell,
                  let asset = viewModel.result.value?.assets[safe: indexPath.item] else { return }
            cell.selectedNumber = selectedAssets.firstIndex(where: { $0 == asset })
        }
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
        cell.selectedNumber = selectedAssets.firstIndex(where: { $0 == asset })

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
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - (minimumLineSpacing * CGFloat(numberOfItemInLine - 1))) / CGFloat(numberOfItemInLine)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        return cellSize
    }
}
