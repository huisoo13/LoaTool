//
//  AdditionalTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/30.
//

import UIKit

class AdditionalTableViewCell: UITableViewCell {

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let numberOfLimitCompleted = 3

    // 수정 - 003: 스크롤 변경
    // 해당 부분 버그 발견 시 검토
    var isDragging: Bool = false
    //
    var data: AdditionalContent? {
        didSet {
            guard let data = data else {
                return
            }

            switch data.type / 10 {
            case 1:
                typeView.backgroundColor = .systemRed
            case 2:
                typeView.backgroundColor = .systemYellow
            case 3:
                typeView.backgroundColor = .systemGreen
            case 4:
                typeView.backgroundColor = .systemBlue
            default:
                break
            }
            
            let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")

            addObserver()
            
            iconImageView.image = UIImage(named: "content.icon.\(data.icon)")
            nameLabel.text = data.title
            nameLabel.textColor = data.weekday.contains(DateManager.shared.currentWeekday()) ? .label : .systemRed
            
            updatedView(data)

            showCharacterList = showExcludedMember ? true : nil
            button.isHidden = showExcludedMember
            
            collectionView.reloadData()
            
            let contentOffset: CGPoint = data.type % 10 != 0 ? CGPoint(x: UserDefaults.standard.double(forKey: "additionalContentOffsetX"), y: 0) : .zero
            collectionView.contentOffset = contentOffset

        }
    }
    
    var showCharacterList: Bool? {
        didSet {
            guard let showCharacterList = showCharacterList else {
                collectionView.isHidden = true
                desciptionLabel.isHidden = false
                button.transform = .identity

                return
            }
                        
            UIView.animate(withDuration: 0.1, animations: {
                self.collectionView.isHidden = !showCharacterList
                self.desciptionLabel.isHidden = showCharacterList

                self.button.transform = showCharacterList ? CGAffineTransform(rotationAngle:  .pi / 4) : .identity
            })
                        

            let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
            if !showExcludedMember {
                collectionView.reloadData()
                collectionView.contentOffset = .zero
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        setupView()
        setupCollectionView()
        addObserver()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupView() {
        typeView.layer.cornerRadius = typeView.bounds.height / 2
        
        iconView.layer.cornerRadius = 6
        iconView.layer.borderWidth = 0.5
        iconView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func addObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        // 수정 - 003
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "additionalDidScroll"), object: nil)
        
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if let data = self.data, data.type % 10 != 0, showExcludedMember {
            NotificationCenter.default.addObserver(self, selector: #selector(additionalDidScroll(_:)), name: NSNotification.Name(rawValue: "additionalDidScroll"), object: nil)
        }
        //
    }
    
    @objc func reloadData(_ sender: NSNotification) {
        collectionView.reloadData()
        
        guard let data = self.data else { return }
        updatedView(data)
    }
    
    // 수정 - 003
    @objc func additionalDidScroll(_ sender: NSNotification) {
        let contentOffset = sender.object as? CGPoint ?? .zero
        collectionView.contentOffset = contentOffset
    }
    //
    
    func updatedView(_ data: AdditionalContent) {
        let numberOfOverflow = inspectionNumberOfOverflow(data)
        let count = data.included.count - data.completed.count - numberOfOverflow

        switch data.type % 10 {
        case 0:
            desciptionLabel.attributedText = count > 0
            ? "\(count)개의 원정대가 남았습니다."
                .attributed(of: "\(count)개", key: .foregroundColor, value: UIColor.custom.textBlue)
                .addAttribute(of: "\(count)개", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
            : "모든 원정대를 완료했습니다."
                .attributed(of: "모든 원정대를 완료했습니다.", key: .foregroundColor, value: UIColor.systemPurple)
                .addAttribute(of: "모든 원정대를 완료했습니다.", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
        case 1:
            desciptionLabel.attributedText = count > 0
            ? "\(count)개의 캐릭터가 남았습니다."
                .attributed(of: "\(count)개", key: .foregroundColor, value: UIColor.custom.textBlue)
                .addAttribute(of: "\(count)개", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
            : "모든 캐릭터를 완료했습니다."
                .attributed(of: "모든 캐릭터를 완료했습니다.", key: .foregroundColor, value: UIColor.systemPurple)
                .addAttribute(of: "모든 캐릭터를 완료했습니다.", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
        default:
            break
        }
    }
    
    func inspectionNumberOfOverflow(_ data: AdditionalContent) -> Int {
        var numberOfOverflow = 0
        
        if data.type / 10 == 4 {
            guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return 0 }
            
            // 수정 - 004: 동일 군단장 설정
            data.included.forEach { identifier in
                if data.completed.contains(identifier) { return }
                
                var numberOfCompleted = 0
                var linkingContent: [String] = []
                additional.forEach { content in
                    if content.type >= 40 && content.completed.contains(identifier) {
                        numberOfCompleted += 1

                        if linkingContent.contains(content.link) && content.link != "" {
                            numberOfCompleted -= 1
                        } else if content.link != "" {
                            linkingContent.append(content.link)
                        }
                    }
                }

                
                let link = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(identifier) && content.link != ""
                }.map { content in content.link }
                
                let isLinkingContentCompleted = link.contains(data.link)
                
                if numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(identifier) && !isLinkingContentCompleted {
                    numberOfOverflow += 1
                }
            }
        }

        return numberOfOverflow
    }

}

extension AdditionalTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = showExcludedMember ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16) : .zero

        collectionView.register(UINib(nibName: "AdditionalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdditionalCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if showExcludedMember {
            // 수정 - 003
            guard let data = self.data,
                  let member = RealmManager.shared.readAll(Todo.self).first?.member else { return 0 }

            let filter = Array(member).filter({ data.type % 10 == $0.category })
            return filter.count
        } else {
            guard let data = self.data else { return 0 }
            return data.included.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if showExcludedMember {
            // 수정 - 003
            guard let data = self.data,
                  let member = RealmManager.shared.readAll(Todo.self).first?.member,
                  let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] else { return .zero }

            let count = filter.name.count
            let width = max(40, CGFloat(10 * count))
            
            return CGSize(width: width, height: 60)
        } else {
            guard let data = self.data,
                  let identifier = data.included[safe: indexPath.item] else { return .zero }
            
            let member = RealmManager.shared.read(Member.self, identifier: identifier).first
            let count = member?.name.count ?? 4
            let width = max(40, CGFloat(10 * count))
            
            return CGSize(width: width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if showExcludedMember {
            // 수정 - 003
            guard let cell = cell as? AdditionalCollectionViewCell,
                  let data = self.data,
                  let member = RealmManager.shared.readAll(Todo.self).first?.member,
                  let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] else { return }
            
            let isIncluded = data.included.contains(filter.identifier)
            cell.contentView.isHidden = !isIncluded
            
            cell.completed = data.completed.contains(filter.identifier)

            if data.type >= 40 {
                guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
                
                // 수정 - 004: 동일 군단장 설정 + AdvancedContentViewController
                var numberOfCompleted = 0
                var linkingContent: [String] = []
                additional.forEach { content in
                    if content.type >= 40 && content.completed.contains(filter.identifier) {
                        numberOfCompleted += 1

                        if linkingContent.contains(content.link) && content.link != "" {
                            numberOfCompleted -= 1
                        } else if content.link != "" {
                            linkingContent.append(content.link)
                        }
                    }
                }
                
                let link = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(filter.identifier) && content.link != ""
                }.map { content in content.link }
                
                let isLinkingContentCompleted = link.contains(data.link)
                
                cell.nameLabel.textColor = numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(filter.identifier)
                ? (isLinkingContentCompleted ? .label : .systemRed)
                : ( numberOfCompleted >= (self.numberOfLimitCompleted - 1) && !data.completed.contains(filter.identifier) ? (isLinkingContentCompleted ? .label : .systemPurple) : .label)
                //
            } else {
                cell.nameLabel.textColor = .label
            }
            
            //
        } else {
            guard let cell = cell as? AdditionalCollectionViewCell,
                  let data = self.data,
                  let identifier = data.included[safe: indexPath.item] else { return }

            cell.contentView.isHidden = false
            cell.completed = data.completed.contains(identifier)
            
            if data.type >= 40 {
                guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
                
                // 수정 - 004
                var numberOfCompleted = 0
                var linkingContent: [String] = []
                additional.forEach { content in
                    if content.type >= 40 && content.completed.contains(identifier) {
                        numberOfCompleted += 1

                        if linkingContent.contains(content.link) && content.link != "" {
                            numberOfCompleted -= 1
                        } else if content.link != "" {
                            linkingContent.append(content.link)
                        }
                    }
                }
                
                let link = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(identifier) && content.link != ""
                }.map { content in content.link }
                
                let isLinkingContentCompleted = link.contains(data.link)
                
                cell.nameLabel.textColor = numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(identifier)
                ? (isLinkingContentCompleted ? .label : .systemRed)
                : ( numberOfCompleted >= (self.numberOfLimitCompleted - 1) && !data.completed.contains(identifier) ? (isLinkingContentCompleted ? .label : .systemPurple) : .label)
                //
            } else {
                cell.nameLabel.textColor = .label
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdditionalCollectionViewCell", for: indexPath) as! AdditionalCollectionViewCell
        
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if showExcludedMember {
            // 수정 - 003
            if let data = self.data,
               let member = RealmManager.shared.readAll(Todo.self).first?.member,
               let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] {
                cell.data = filter
            }
            //
        } else {
            if let data = self.data,
               let identifier = data.included[safe: indexPath.item] {
                let member = RealmManager.shared.read(Member.self, identifier: identifier).first
                cell.data = member
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if showExcludedMember {
            // 수정 - 003
            guard let cell = collectionView.cellForItem(at: indexPath) as? AdditionalCollectionViewCell,
                  let data = self.data,
                  let member = RealmManager.shared.readAll(Todo.self).first?.member,
                  let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] else { return }

            var isExceeded = false

            if !data.included.contains(filter.identifier) { return }
            
            RealmManager.shared.update {
                if data.completed.contains(filter.identifier) {
                    guard let index = data.completed.firstIndex(of: filter.identifier) else { return }
                    data.completed.remove(at: index)
                } else {
                    if data.type >= 40 {
                        var numberOfCompleted = 0

                        guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
                        // 수정 - 004
                        var linkingContent: [String] = []
                        additional.forEach { content in
                            if content.type >= 40 && content.completed.contains(filter.identifier) {
                                numberOfCompleted += 1

                                if linkingContent.contains(content.link) && content.link != "" {
                                    numberOfCompleted -= 1
                                } else if content.link != "" {
                                    linkingContent.append(content.link)
                                }
                            }
                        }
                        
                        let link = additional.filter { content in
                            return content.type >= 40 && content.completed.contains(filter.identifier) && content.link != ""
                        }.map { content in content.link }
                        
                        let isLinkingContentCompleted = link.contains(data.link)
                        
                        switch (numberOfCompleted >= self.numberOfLimitCompleted, isLinkingContentCompleted) {
                        case (true, false):
                            isExceeded = true
                            return
                        default:
                            break
                        }
                        //
                    }
                    
                    data.completed.append(filter.identifier)
                }
            }
            
            if isExceeded { return }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
            
            cell.data = filter
            cell.completed = data.completed.contains(filter.identifier)
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? AdditionalCollectionViewCell,
                  let data = self.data,
                  let identifier = data.included[safe: indexPath.item] else { return }
                  
            var isExceeded = false
            
            RealmManager.shared.update {
                if data.completed.contains(identifier) {
                    guard let index = data.completed.firstIndex(of: identifier) else { return }
                    data.completed.remove(at: index)
                } else {
                    if data.type >= 40 {
                        var numberOfCompleted = 0

                        guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
                        // 수정 - 004
                        var linkingContent: [String] = []
                        additional.forEach { content in
                            if content.type >= 40 && content.completed.contains(identifier) {
                                numberOfCompleted += 1

                                if linkingContent.contains(content.link) && content.link != "" {
                                    numberOfCompleted -= 1
                                } else if content.link != "" {
                                    linkingContent.append(content.link)
                                }
                            }
                        }
                        
                        let link = additional.filter { content in
                            return content.type >= 40 && content.completed.contains(identifier) && content.link != ""
                        }.map { content in content.link }
                        
                        let isLinkingContentCompleted = link.contains(data.link)
                        
                        switch (numberOfCompleted >= self.numberOfLimitCompleted, isLinkingContentCompleted) {
                        case (true, false):
                            isExceeded = true
                            return
                        default:
                            break
                        }
                        //
                    }
                    
                    data.completed.append(identifier)
                }
            }
            
            if isExceeded { return }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
            
            let member = RealmManager.shared.read(Member.self, identifier: identifier).first
            cell.data = member
            cell.completed = data.completed.contains(identifier)
        }
    }
}

// 수정 - 003
extension AdditionalTableViewCell: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        isDragging = showExcludedMember ? true : false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if !isDragging && !showExcludedMember { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "additionalDidScroll"), object: scrollView.contentOffset)
        UserDefaults.standard.set(scrollView.contentOffset.x, forKey: "additionalContentOffsetX")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
    }
}
//
