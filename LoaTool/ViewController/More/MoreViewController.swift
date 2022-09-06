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

    let cellSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32) / (64 / 33))
    let minimumLineSpacing: CGFloat = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")
        
        setupTableView()
        setupCollectionView()
        
        data = Array(RealmManager.shared.readAll(AD.self))
        
        Parsing.shared.downloadHTMLForAD() { result in
            RealmManager.shared.delete(AD.self)
            RealmManager.shared.add(result)
            
            self.data = result
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
        
        self.tableView.reloadData()
        self.collectionView.reloadData()
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
        7
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
                
                Alert.message(self, title: "설정 완료", message: "앱 재실행 후 적용됩니다.", option: .onlySuccessAction, handler: nil)
            }
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

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
                
        cell.data = data[indexPath.item]
        
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
        
        targetContentOffset.pointee = CGPoint(x: (CGFloat(index) * cellWidthIncludingSpacing) - (minimumLineSpacing * 2), y: 0)
    }
}
