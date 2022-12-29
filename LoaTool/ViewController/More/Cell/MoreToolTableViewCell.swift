//
//  MoreToolTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/14.
//

import UIKit

class MoreToolTableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var coordinator: AppCoordinator?
    var target: UIViewController = UIViewController()
    
    var data: [AD] = []

    var timer: Timer = Timer()
    var cellSize: CGSize = .zero
    let minimumLineSpacing: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        setupCollectionView()
        setupData()
        setupView()
        setupGestureRecognizer()
    }
    
    func setupView() {
        stackView.layer.borderColor = UIColor.systemGray4.cgColor
        stackView.layer.borderWidth = 0.5
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            view.addGestureRecognizer { _ in
                switch i {
                case 0:
                    self.coordinator?.pushToProfitAndLossViewController(animated: true)
                case 1:
                    let usingCloudKit = UserDefaults.standard.bool(forKey: "usingCloudKit")
                    let message = usingCloudKit ? "동기화를 중지해도 기존의 데이터는 남아있습니다.\n\n동기화를 중지하시겠습니까?" : "동일한 iCloud에 로그인 되어있는 기기에서 데이터를 동기화합니다.\n\n해당 기능을 사용 하시겠습니까?"
                    Alert.message(self.target, title: "iCloud 동기화", message: message, option: .successAndCancelAction) { _ in
                        UserDefaults.standard.set(!usingCloudKit, forKey: "usingCloudKit")
                        
                        if !usingCloudKit {
                            CloudManager.shared.commit()
                        }
                        
                        Alert.message(self.target, title: "설정 완료", message: "앱 재실행 후 적용됩니다.\n 재실행 후 '할 일' 탭을 확인해주세요. ", option: .onlySuccessAction, handler: nil)
                    }
                case 2:
                    guard let url = URL(string: "https://open.kakao.com/o/sBIbVWyd"), UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case 3:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func setupData() {
        data = Array(RealmManager.shared.readAll(AD.self))
        collectionView.setContentOffset(CGPoint(x: contentOffsetX(for: 0), y: 0), animated: false)

        Parsing.shared.downloadHTMLForAD() { result in
            RealmManager.shared.delete(AD.self)
            RealmManager.shared.add(result)
            
            self.data = result
            self.collectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension MoreToolTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: minimumLineSpacing * 2, bottom: 0, right: minimumLineSpacing * 2)

        collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")

        let height = collectionView.bounds.height
        cellSize = CGSize(width: (height - 16) * (64 / 33), height: height - 16)
        
        resetTimer()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = 2 + data.count + 2
        return data.count <= 1 ? data.count : numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
        let numberOfItems = 2 + data.count + 2
        
        switch indexPath.row {
        case 0:
            cell.data = data[data.count - 2]
        case 1:
            cell.data = data[data.count - 1]
        case numberOfItems - 2:
            cell.data = data[0]
        case numberOfItems - 1:
            cell.data = data[1]
        default:
            cell.data = data[indexPath.item - 2]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let numberOfItems = 2 + data.count + 2
        let urlString: String
        
        switch indexPath.row {
        case 0:
            urlString = data[data.count - 2].URL
        case 1:
            urlString = data[data.count - 1].URL
        case numberOfItems - 2:
            urlString = data[0].URL
        case numberOfItems - 1:
            urlString = data[1].URL
        default:
            urlString = data[indexPath.item - 2].URL
        }
        
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension MoreToolTableViewCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidthIncludingSpacing: CGFloat = cellSize.width + minimumLineSpacing

        let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
        let index: Int
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        } else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        } else {
            index = Int(round(estimatedIndex))
        }
        
        targetContentOffset.pointee = CGPoint(x: contentOffsetX(for: index), y: 0)
        
        resetTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let numberOfItems = 2 + data.count + 2
        
        if contentOffset.x > contentOffsetX(for: numberOfItems - 2) {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(for: 2), y: 0), animated: false)
        } else if contentOffset.x < contentOffsetX(for: 1) {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(for: numberOfItems - 3), y: 0), animated: false)
        }
    }
    
    func contentOffsetX(for index: Int) -> CGFloat {
        let cellWidthIncludingSpacing: CGFloat = cellSize.width + minimumLineSpacing
        return (CGFloat(index) * cellWidthIncludingSpacing) - (minimumLineSpacing * 2)
    }
    
    func resetTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { timer in
            let cellWidthIncludingSpacing: CGFloat = self.cellSize.width + self.minimumLineSpacing
            let estimatedIndex = self.collectionView.contentOffset.x / cellWidthIncludingSpacing
            let index = Int(round(estimatedIndex))

            let numberOfItems = 2 + self.data.count + 2
            
            if index == numberOfItems - 2 {
                self.collectionView.setContentOffset(CGPoint(x: self.contentOffsetX(for: 2), y: 0), animated: false)
            }

            if self.data.count <= 1 { return }

            let next = index + 1
            self.collectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
        })
    }
}
