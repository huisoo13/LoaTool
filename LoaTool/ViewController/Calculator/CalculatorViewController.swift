//
//  CalculatorViewController.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit

class CalculatorViewController: UIViewController, Storyboarded {
    weak var coordinator: AppCoordinator?

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupPageControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.reloadData()
        }, completion: { _ in
            self.collectionView.reloadData()
        })
    }

}

extension CalculatorViewController {
    fileprivate func setupNavigationBar() {
        setTitle("각인 계산기".localized, size: 20)
        
        let search = UIBarButtonItem(title: "검색", style: .plain, target: self, action: #selector(touchUpInside(_:)))
        search.tintColor = .systemBlue
//        search.isEnabled = false

        addRightBarButtonItems([search])
    }
    
    @objc func touchUpInside(_ sender: UIBarButtonItem) {
        coordinator?.pushToCalculatorResultViewController(animated: true)
    }
}

extension CalculatorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.contentInset = .zero
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(UINib(nibName: "CalculatorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CalculatorCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width > 375 * 2
        ? collectionView.bounds.width / 2
        : collectionView.bounds.width
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = collectionView.bounds.width > 375 * 2 ? 10 : 1
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = collectionView.bounds.width > 375 * 2 ? 10 : 1
        
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalculatorCollectionViewCell", for: indexPath) as! CalculatorCollectionViewCell
        
        cell.index = indexPath.item
        cell.coordinator = coordinator
        cell.data = Calculator.importPreviousData()
        
        switch indexPath.item {
        case 0:
            break
        case 1:
            break
        default:
            break
        }
        
        return cell

    }
}

extension CalculatorViewController: UIScrollViewDelegate {
    func setupPageControl() {
        pageControl.numberOfPages = 2
        pageControl.isUserInteractionEnabled = false
        
        pageControl.setIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8)), forPage: 0)
        pageControl.setIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8)), forPage: 1)
        
        if #available(iOS 16.0, *) {
            pageControl.setCurrentPageIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)), forPage: 0)
            pageControl.setCurrentPageIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)), forPage: 1)
        }

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidthIncludingSpacing: CGFloat = scrollView.bounds.width

        let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
        let index: Int
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        } else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        } else {
            index = Int(round(estimatedIndex))
        }
        
        pageControl.currentPage = index
    }
}
