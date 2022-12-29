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
        
    weak var coordinator: AppCoordinator?
    
    var data: [AD] = []

    var timer: Timer = Timer()
    var cellSize: CGSize = .zero
    let minimumLineSpacing: CGFloat = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdateRealmFromCloudKit(_:)), name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        collectionView.reloadData()
//        collectionView.setContentOffset(CGPoint(x: contentOffsetX(for: 2), y: 0), animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.reloadData()
        }, completion: { _ in
            self.tableView.reloadData()
        })
    }
    
    @objc func endUpdateRealmFromCloudKit(_ sender: NSNotification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        tableView.register(UINib(nibName: "MoreToolTableViewCell", bundle: nil), forCellReuseIdentifier: "MoreToolTableViewCell")

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView

        switch section {
        case 0:
            header.label.text = "설정"
        case 1:
            header.label.text = "서비스"
        case 2:
            header.label.text = "앱 정보"
        default:
            break
        }
        
        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
            default:
                break
            }

            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreToolTableViewCell", for: indexPath) as! MoreToolTableViewCell

            cell.coordinator = coordinator
            cell.target = self
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell", for: indexPath) as! MoreTableViewCell
            
            switch indexPath.row {
            case 0:
                cell.setupCell(title: "공지사항",
                               image: UIImage(systemName: "megaphone", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                               subTitle: nil,
                               subImage: nil,
                               showChevron: true)
            case 1:
                cell.setupCell(title: "버전정보",
                               image: UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                               subTitle: Version.now(),
                               subImage: nil,
                               showChevron: true)
            case 2:
                cell.setupCell(title: "오픈 소스 라이브러리",
                               image: UIImage(systemName: "doc.plaintext", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                               subTitle: nil,
                               subImage: nil,
                               showChevron: true)
                /*
            case 3:
                cell.setupCell(title: "고객센터",
                               image: UIImage(systemName: "bubble.left.and.exclamationmark.bubble.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .thin)) ?? UIImage(),
                               subTitle: nil,
                               subImage: UIImage(named: "icon.kakao"),
                               showChevron: true)
                 */
            default:
                break
            }
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if User.shared.isConnected { return }
                coordinator?.pushToMainCharacterViewController(animated: true)
            case 1:
                coordinator?.pushToRegisterViewController(animated: true)
            default:
                break
            }
        case 1:
            break
        case 2:
            switch indexPath.row {
            case 0:
                guard let url = URL(string: "https://huisoo.tistory.com/10"), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            case 1:
                guard let url = URL(string: "https://apps.apple.com/kr/app/id1580507503"), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            case 2:
                coordinator?.pushToOpenSourceLibraryViewController(animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}
