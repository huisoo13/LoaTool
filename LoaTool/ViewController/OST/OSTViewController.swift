//
//  OSTViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/02.
//

import UIKit
import Kingfisher

class OSTViewController: UIViewController, Storyboarded {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    weak var coordinator: AppCoordinator?

    var viewModel: OSTViewModel = OSTViewModel()
    var numberOfItem: Int = 0
    var imageView: UIImageView = UIImageView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupView()
        setupItemViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func setupView() {
        contentView.isUserInteractionEnabled = false

        playButton.layer.cornerRadius = playButton.bounds.height / 2
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 0.5
    }
    
    func setupGestureRecognizer() {
        // TODO: dismissButton.superView UIPinGestureRecognizer 추가하기
    }
    
    fileprivate func setupItemViewModelObserver() {
        viewModel.data.bind { data in
            self.numberOfItem = data?.count ?? 0
            self.collectionView.reloadData()
            self.viewModel.isDragging.value = false
        }
        
        viewModel.isDragging.bind { isDragging in
            guard let collectionViewLayout = self.collectionView.collectionViewLayout as? CollectionViewLayout,
                  let isDragging = isDragging else { return }
             
            if isDragging {
                self.hideContentView(animated: true)
            } else {
                self.showContentView(animated: true)
                let index = min(collectionViewLayout.selectedIndex, (self.viewModel.data.value?.count ?? 0) - 1)
                self.viewModel.selectedItem.value = self.viewModel.data.value?[safe: index]
            }
        }
        
        viewModel.selectedItem.bind { [self] item in
            guard let item = item else { return }
            
            let imageURL = URL(string: item.imageURL)
            imageView.kf.setImage(with: imageURL)
            
            contentView.subviews.enumerated().forEach { i, view in
                switch i {
                case 0:
                    guard let albumLabel = view as? UILabel else { return }
                    albumLabel.text = item.album
                case 1:
                    // TODO: pod 'MarqueeLabel' 추가하기
                    guard let titleLabel = view as? UILabel else { return }
                    titleLabel.text = item.title
                case 2:
                    guard let artistLabel = view as? UILabel else { return }
                    artistLabel.text = item.artist
                default:
                    break
                }
            }
        }
        
        viewModel.configure()
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        coordinator?.dismiss(animated: true)
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        // TODO: OSTPlayerViewController 이동하기 추가
    }
    
    // TODO: animation 효과 if문 추가하기 + LP판 이미지 및 효과 추가하기
    func showContentView(animated: Bool) {
        contentView.alpha = 0
        contentView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 1
        }
        
        imageView.isHidden = false
    }
    
    func hideContentView(animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 0
        } completion: { _ in
            self.contentView.isHidden = true
        }
        
        imageView.isHidden = true
    }
}

extension OSTViewController {
    fileprivate func setupNavigationBar() {
        setTitle("OST".localized, size: 20)
    }
}

extension OSTViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.clipsToBounds = false
        collectionView.showsVerticalScrollIndicator = false
        
        let collectionViewLayout = CollectionViewLayout()
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(UINib(nibName: "OSTCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OSTCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItem
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewLayout = collectionView.collectionViewLayout as? CollectionViewLayout else { return }

        let index = min(collectionViewLayout.selectedIndex, (self.viewModel.data.value?.count ?? 0) - 1)

        let selectedIndexPath = IndexPath(item: index, section: 0)
        if indexPath == selectedIndexPath && !collectionView.isDragging {
            let point = collectionView.layoutAttributesForItem(at: indexPath)?.center ?? .zero
            let center = collectionView.convert(point, to: collectionView.superview)
            
            imageView.removeFromSuperview()

            imageView.frame = CGRect(origin: .zero, size: collectionViewLayout.itemSize)
            imageView.center = center
            imageView.layer.cornerRadius = 4

            imageView.isUserInteractionEnabled = false

            contentView.addSubview(imageView)
            
            viewModel.isDragging.value = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OSTCollectionViewCell", for: indexPath) as! OSTCollectionViewCell
        
        cell.data = viewModel.data.value?[safe: indexPath.item]
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension OSTViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.isDragging.value = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.isDragging.value = false

    }
}
