//
//  ImageViewerViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/04.
//

import UIKit
import Kingfisher

class ImageViewerViewController: UIViewController, Storyboarded {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var coordinator: AppCoordinator?
    
    var images: [UIImage]?
    var imageURL: [String]?
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var initialCenter: CGPoint = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")
        
        setupCollectionView()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        

    }
    
    func setupGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(fullToDismiss(_:)))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func fullToDismiss(_ sender: UIPanGestureRecognizer) {
        let transition = sender.translation(in: collectionView)

        let centerXDiff = initialCenter.x - collectionView.center.x
        let centerYDiff = initialCenter.y - collectionView.center.y

        switch sender.state {
        case .began:
            initialCenter = collectionView.center
            collectionView.isScrollEnabled = false
        case .changed:
            let changedX = collectionView.center.x + transition.x
            let changedY = collectionView.center.y + transition.y

            collectionView.center = CGPoint(x: changedX, y: changedY)
            
            collectionView.alpha = 1 - (0.2 * (sqrt(pow(centerXDiff, 2) + pow(centerYDiff, 2)) / 200))
            backgroundView.alpha = 0.8 - (0.4 * (sqrt(pow(centerXDiff, 2) + pow(centerYDiff, 2)) / 200))
            
            sender.setTranslation(.zero, in: collectionView)
        case .cancelled, .ended, .failed:
            let isOverDiff = sqrt(pow(centerXDiff, 2) + pow(centerYDiff, 2)) > abs(200)
            
            if isOverDiff {
                coordinator?.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.center = self.initialCenter
                    self.collectionView.alpha = 1
                    self.backgroundView.alpha = 0.8
                })
            }
            
            collectionView.isScrollEnabled = true
        default:
            break
        }
    }
}

extension ImageViewerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: "ImageViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCollectionViewCell")

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = self.images { return images.count }
        if let imageURL = self.imageURL { return imageURL.count }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionViewCell", for: indexPath) as! ImageViewCollectionViewCell
        
        if let images = self.images { cell.image = images[indexPath.row] }
        if let imageURL = self.imageURL { cell.imageURL = imageURL[indexPath.row] }

        cell.delegate = self
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.dismiss(animated: true)
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        panGestureRecognizer.isEnabled = false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        panGestureRecognizer.isEnabled = true
    }
}

extension ImageViewerViewController: ImageViewerDelegate {
    func imageViewer(_ imageView: UIImageView, isZooming: Bool) {
        collectionView.isScrollEnabled = !isZooming
    }
}

extension ImageViewerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = gestureRecognizer.velocity(in: collectionView)
        
        if abs(velocity.x) < abs(velocity.y * 1.5) { return false }
        if otherGestureRecognizer == panGestureRecognizer { return false }
        
        return true
    }
    
    
}
