//
//  MoreViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/28.
//

import UIKit
import RealmSwift

class MoreViewController: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var hideBannerButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var coordinator: AppCoordinator?
    
    var data: [AD] = []

    var timer: Timer = Timer()
    var cellSize: CGSize = .zero
    let minimumLineSpacing: CGFloat = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupCollectionView()
        
        data = Array(RealmManager.shared.readAll(AD.self))
        
        Parsing.shared.downloadHTMLForAD() { result in
            RealmManager.shared.delete(AD.self)
            RealmManager.shared.add(result)
            
            self.data = result
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(CGPoint(x: self.contentOffsetX(for: 2), y: 0), animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.collectionView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: contentOffsetX(for: 2), y: 0), animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.setupView()
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }, completion: { _ in
            self.setupView()
            self.tableView.reloadData()
            self.collectionView.reloadData()
        })
    }
    
    @objc func endUpdateRealmFromCloudKit(_ sender: NSNotification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    func setupView() {
        let height = collectionView.bounds.height
        cellSize = CGSize(width: (height - 32) * (64 / 33), height: height - 32)
    }
    
    @IBAction func hideBannerAction(_ sender: UIButton) {
        bannerView.isHidden = true
    }
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "MoreTableViewCell", bundle: nil), forCellReuseIdentifier: "MoreTableViewCell")

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView

        header.label.text = "메뉴"
        
        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell", for: indexPath) as! MoreTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.setupCell(title: "대표 캐릭터 설정",
                           image: UIImage(systemName: "tag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: User.shared.name,
                           subImage: nil,
                           showChevron: true)
        case 1:
            cell.setupCell(title: "본인 인증",
                           image: UIImage(systemName: "person.fill.viewfinder", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: User.shared.isConnected ? "인증 완료" : (User.shared.identifier == "" ? "미인증" : "만료"),
                           subTitleColor: User.shared.isConnected ? .custom.qualityBlue : .custom.qualityRed,
                           subImage: nil,
                           showChevron: true)
        case 2:
            cell.setupCell(title: "공지사항",
                           image: UIImage(systemName: "megaphone", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: nil,
                           subImage: nil,
                           showChevron: true)
        case 3:
            cell.setupCell(title: "버전정보",
                           image: UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: Version.now(),
                           subImage: nil,
                           showChevron: true)
        case 4:
            cell.setupCell(title: "고객센터",
                           image: UIImage(systemName: "bubble.left.and.exclamationmark.bubble.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: nil,
                           subImage: UIImage(named: "icon.kakao"),
                           showChevron: true)
        case 5:
            cell.setupCell(title: "오픈 소스 라이브러리",
                           image: UIImage(systemName: "doc.plaintext", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: nil,
                           subImage: nil,
                           showChevron: true)
        case 6:
            cell.setupCell(title: "iCloud 동기화",
                           image: UIImage(systemName: "icloud", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: "Beta",
                           subTitleColor: .custom.qualityRed,
                           subImage: nil,
                           showChevron: true)
            
            cell.subLabel.font = .italicSystemFont(ofSize: 12)
        case 7:
            cell.setupCell(title: "OST",
                           image: UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                           subTitle: nil,
                           subImage: nil,
                           showChevron: true)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if User.shared.isConnected { return }
            coordinator?.pushToMainCharacterViewController(animated: true)
        case 1:
            coordinator?.pushToRegisterViewController(animated: true)
        case 2:
            guard let url = URL(string: "https://huisoo.tistory.com/10"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 3:
            guard let url = URL(string: "https://apps.apple.com/kr/app/id1580507503"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 4:
            guard let url = URL(string: "https://open.kakao.com/o/sBIbVWyd"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 5:
            coordinator?.pushToOpenSourceLibraryViewController(animated: true)
        case 6:
            let usingCloudKit = UserDefaults.standard.bool(forKey: "usingCloudKit")
            let message = usingCloudKit ? "동기화를 중지해도 기존의 데이터는 남아있습니다.\n\n동기화를 중지하시겠습니까?" : "동일한 iCloud에 로그인 되어있는 기기에서 데이터를 동기화합니다.\n\n해당 기능을 사용 하시겠습니까?"
            Alert.message(self, title: "iCloud 동기화", message: message, option: .successAndCancelAction) { _ in
                UserDefaults.standard.set(!usingCloudKit, forKey: "usingCloudKit")
                
                if !usingCloudKit {
                    CloudManager.shared.commit()
                }
                
                Alert.message(self, title: "설정 완료", message: "앱 재실행 후 적용됩니다.\n 재실행 후 '할 일' 탭을 확인해주세요. ", option: .onlySuccessAction, handler: nil)
            }
        case 7:
            coordinator?.presentToOSTViewController(animated: true)
        default:
            break
        }
    }
}

extension MoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: minimumLineSpacing * 2, bottom: 0, right: minimumLineSpacing * 2)

        collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")

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
        guard let url = URL(string: data[indexPath.item].URL), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

    }
}

extension MoreViewController: UIScrollViewDelegate {
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
