//
//  CalculatorResultViewController.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/14.
//

import UIKit

class CalculatorResultViewController: UIViewController, Storyboarded {
    weak var coordinator: AppCoordinator?

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    
    let apiKey: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IktYMk40TkRDSTJ5NTA5NWpjTWk5TllqY2lyZyIsImtpZCI6IktYMk40TkRDSTJ5NTA5NWpjTWk5TllqY2lyZyJ9.eyJpc3MiOiJodHRwczovL2x1ZHkuZ2FtZS5vbnN0b3ZlLmNvbSIsImF1ZCI6Imh0dHBzOi8vbHVkeS5nYW1lLm9uc3RvdmUuY29tL3Jlc291cmNlcyIsImNsaWVudF9pZCI6IjEwMDAwMDAwMDAxNzM0NDYifQ.CwVouwVUh2DNkgDgoWd4ZMzTPQUUv0l1E7IqbaGZo-FqmraAyq6wXRIYwtIG57jQR64kILWoXxg1g93Hx2ACVZFR_n_OlsUteSLJIChpcAcWlItn8Q6JMrYMj6HVVuzUvn0aR2BwJZaCX9nj7iprR1LRt42A7Bl9VfMWsDW_fDXHhVRTxJ45lTgRhUwr9ICwi6ivxAAo25iyNYTgL5_QTTlMFyFmuKNLnL6UOGtRLV8FMsOJHWr051MjSUg7dyPYkhs1tPr6g73j2z-A7FPdHRiZTtrJ282frMMIeRjOFpJoeLnVyndKVhJnyu2OCLVT1a75HIggjgVwyjIJvgZk1A"
    
    var data: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupPageControl()
        
        let data: AuctionRequest = AuctionRequest(itemLevelMin: 0,
                                                  itemLevelMax: 1700,
                                                  itemGradeQuality: 90,
                                                  skillOptions: [],
                                                  etcOptions: [
                                                    RequestOption(firstOption: 2,
                                                                  secondOption: 15,
                                                                  minValue: 0,
                                                                  maxValue: 999),
                                                    RequestOption(firstOption: 3,
                                                                  secondOption: 118,
                                                                  minValue: 3,
                                                                  maxValue: 3),
                                                    RequestOption(firstOption: 3,
                                                                  secondOption: 247,
                                                                  minValue: 5,
                                                                  maxValue: 6)
                                                  ],
                                                  categoryCode: 200030,
                                                  characterClass: "",
                                                  itemTier: 3,
                                                  itemGrade: "",
                                                  itemName: "",
                                                  pageNo: 1)
        
        API.post.searchAuctions(data, forKey: apiKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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


extension CalculatorResultViewController {
    fileprivate func setupNavigationBar() {
        setTitle("검색 결과".localized, size: 20)
    }
}

extension CalculatorResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.contentInset = .zero
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(UINib(nibName: "CalculatorResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CalculatorResultCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalculatorResultCollectionViewCell", for: indexPath) as! CalculatorResultCollectionViewCell
        
        
        return cell

    }
}

extension CalculatorResultViewController: UIScrollViewDelegate {
    func setupPageControl() {
        pageControl.numberOfPages = data.count
        pageControl.isUserInteractionEnabled = false
        
        
        for i in data {
            pageControl.setIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8)), forPage: i)

            if #available(iOS 16.0, *) {
                pageControl.setCurrentPageIndicatorImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)), forPage: i)
            }
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
