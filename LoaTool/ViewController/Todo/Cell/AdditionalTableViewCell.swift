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
    
    let numberOfLimitCompleted = 3 // 골드 보상 3회 제한
    
    var isDragging: Bool = false
    
    var target: UIViewController?
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
            
            let weekday = DateManager.shared.currentWeekday()
            let yesterday = weekday == 1 ? 7 : weekday - 1
            let isAfterAM6 = DateManager.shared.isAfterAM6
            
            if data.weekday.contains(weekday) && isAfterAM6 {
                nameLabel.textColor = .label
            } else if data.weekday.contains(yesterday) && !isAfterAM6 {
                nameLabel.textColor = .label
            } else {
                nameLabel.textColor = .systemRed
            }
            
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
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "additionalDidScroll"), object: nil)
        
        let showExcludedMember: Bool = UserDefaults.standard.bool(forKey: "showExcludedMember")
        if let data = self.data, data.type % 10 != 0, showExcludedMember {
            NotificationCenter.default.addObserver(self, selector: #selector(additionalDidScroll(_:)), name: NSNotification.Name(rawValue: "additionalDidScroll"), object: nil)
        }
    }
    
    @objc func reloadData(_ sender: NSNotification) {
        collectionView.reloadData()
        
        guard let data = self.data else { return }
        updatedView(data)
    }
    
    @objc func additionalDidScroll(_ sender: NSNotification) {
        let contentOffset = sender.object as? CGPoint ?? .zero
        collectionView.contentOffset = contentOffset
    }
    
    func updatedView(_ data: AdditionalContent) {
        let numberOfOverflow = inspectionNumberOfOverflow(data)
        
        let usingTakenGold: Bool = UserDefaults.standard.bool(forKey: "usingTakenGold")
        let count = data.included.count - data.completed.count - (usingTakenGold ? 0 : numberOfOverflow)
        
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
    
    // !!!: 22.2.23 군단장 3회 제한이 골드 획득 3회 제한으로 변경됨에 따라 complete 를 takenGold 로 변경하여 사용 가능
    //      기존의 기능을 유지하며 골드 획득 3회 제한 기능을 추가하기 때문에 해당 코드는 유지
    func inspectionNumberOfOverflow(_ data: AdditionalContent) -> Int {
        var numberOfOverflow = 0
        
        if data.type / 10 == 4 {
            guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return 0 }
            
            // 수정 - 004: 동일 군단장 설정
            data.included.forEach { identifier in
                // STEP 1: 해당 컨텐츠를 완료한 캐릭터가 아니면 return
                if data.completed.contains(identifier) { return }
                
                var numberOfCompleted = 0
                var linkingContent: [String] = []
                
                // STEP 2: 추가 컨텐츠를 반복문으로 확인
                additional.forEach { content in
                    // STEP 3: 군단장 컨텐츠면서 해당 컨텐츠를 완료한 캐릭터인 경우
                    if content.type >= 40 && content.completed.contains(identifier) {
                        // STEP 4: 캐릭터가 완료한 군단장 수 추가
                        numberOfCompleted += 1

                        // STEP 5-1: 만약 해당 컨텐츠의 동일한 링크의 컨텐츠가 완료가 되었다면 완료한 군단장 수 차감
                        if linkingContent.contains(content.link) && content.link != "" {
                            numberOfCompleted -= 1
                        } else if content.link != "" {
                            // STEP 5-2: 완료한 컨텐츠의 링크 값을 저장
                            linkingContent.append(content.link)
                        }
                    }
                }

                // STEP 6-1: 완료된 컨텐츠의 모든 링크 값을 불러오기
                let link = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(identifier) && content.link != ""
                }.map { content in content.link }
                
                // STEP 6-2: 완료된 컨텐츠의 모든 동일 관문 값 불러오기
                let gate = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(identifier) && content.gate != ""
                }.map { content in content.gate }
                
                // STEP 7: 현재 컨텐츠의 링크 값이 완료된 컨텐츠의 링크에 포함하는지 확인
                let isLinkingContentCompleted = link.contains(data.link)
                let isSameGateContentCompleted = gate.contains(data.gate)

                // STEP 8-1: 캐릭터가 완료한 군단장 수가 군단장 클리어 수 제한보다 큰 경우
                //           해당 캐릭터가 해당 컨텐츠를 클리어하지 않은 경우
                //           해당 컨텐츠의 링크 값이 동일한 다른 컨텐츠가 클리어되지 않은 경우
                //           초과된 수 추가
                if numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(identifier) && !isLinkingContentCompleted {
                    numberOfOverflow += 1
                } else if isSameGateContentCompleted {
                    // STEP 8-2: 동일 군단장, 동일 관문을 클리어한 경우 초과된 수 추가
                    numberOfOverflow += 1
                }
            }
        }

        // STEP 9: 해당 컨텐츠를 완료하지 않았지만 군단장 수 제한에 걸려서 완료 할 수 없는 캐릭터의 수 반환
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
        
        guard let cell = cell as? AdditionalCollectionViewCell,
              let data = self.data,
              let member = RealmManager.shared.readAll(Todo.self).first?.member,
              let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] else { return }

        let identifier = showExcludedMember ? filter.identifier : data.included[indexPath.item]

        if showExcludedMember {
            let isIncluded = data.included.contains(filter.identifier)
            cell.contentView.isHidden = !isIncluded
        } else {
            cell.contentView.isHidden = false
        }
        
        cell.completed = data.completed.contains(identifier)

        if data.type >= 40 {
            let usingTakenGold: Bool = UserDefaults.standard.bool(forKey: "usingTakenGold")
            guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }

            var numberOfCompleted = 0
            var linkingContent: [String] = []

            switch usingTakenGold {
            case false:
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

                let gate = additional.filter { content in
                    return content.type >= 40 && content.completed.contains(identifier) && content.gate != ""
                }.map { content in content.gate }

                let isLinkingContentCompleted = link.contains(data.link)
                let isSameGateContentCompleted = gate.contains(data.gate)

                let sameGateContentCompletedColor: UIColor = isSameGateContentCompleted ? .systemRed : .label

                cell.nameLabel.textColor = numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(filter.identifier)
                ? (isLinkingContentCompleted ? sameGateContentCompletedColor : .systemRed)
                : ( numberOfCompleted >= (self.numberOfLimitCompleted - 1) && !data.completed.contains(filter.identifier) ? (isLinkingContentCompleted ? sameGateContentCompletedColor : .systemPurple) : sameGateContentCompletedColor)
            case true:
                additional.forEach { content in
                    if content.type >= 40 && content.takenGold.contains(identifier) {
                        numberOfCompleted += 1

                        if linkingContent.contains(content.link) && content.link != "" {
                            numberOfCompleted -= 1
                        } else if content.link != "" {
                            linkingContent.append(content.link)
                        }
                    }
                }

                let link = additional.filter { content in
                    return content.type >= 40 && content.takenGold.contains(identifier) && content.link != ""
                }.map { content in content.link }

                let gate = additional.filter { content in
                    return content.type >= 40 && content.takenGold.contains(identifier) && content.gate != ""
                }.map { content in content.gate }

                let isLinkingContentCompleted = link.contains(data.link)
                let isSameGateContentCompleted = gate.contains(data.gate)

                let sameGateContentCompletedColor: UIColor = isSameGateContentCompleted ? .systemRed : .label

                cell.nameLabel.textColor = numberOfCompleted >= self.numberOfLimitCompleted && !data.takenGold.contains(filter.identifier)
                ? (isLinkingContentCompleted ? sameGateContentCompletedColor : .systemRed)
                : ( numberOfCompleted >= (self.numberOfLimitCompleted - 1) && !data.takenGold.contains(filter.identifier) ? (isLinkingContentCompleted ? sameGateContentCompletedColor : .systemPurple) : sameGateContentCompletedColor)

            }
        } else {
            cell.nameLabel.textColor = .label
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
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? AdditionalCollectionViewCell,
              let data = self.data,
              let member = RealmManager.shared.readAll(Todo.self).first?.member,
              let filter = Array(member).filter({ data.type % 10 == $0.category })[safe: indexPath.item] else { return }

        let identifier = showExcludedMember ? filter.identifier : data.included[indexPath.item]
        var isExceeded = false

        if showExcludedMember && !data.included.contains(identifier) { return }

        RealmManager.shared.update {
            if data.completed.contains(identifier) {
                guard let index = data.completed.firstIndex(of: identifier) else { return }
                data.completed.remove(at: index)
                
                guard let index = data.takenGold.firstIndex(of: identifier) else { return }
                data.takenGold.remove(at: index)
            } else {
                if data.type >= 40 {
                    var numberOfCompleted = 0
                    
                    guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }

                    let usingTakenGold: Bool = UserDefaults.standard.bool(forKey: "usingTakenGold")
                    switch usingTakenGold {
                    case false:
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
                        
                        let gate = additional.filter { content in
                            return content.type >= 40 && content.completed.contains(identifier) && content.gate != ""
                        }.map { content in content.gate }

                        let isLinkingContentCompleted = link.contains(data.link)
                        let isSameGateContentCompleted = gate.contains(data.gate)

                        switch (numberOfCompleted >= self.numberOfLimitCompleted, isLinkingContentCompleted, isSameGateContentCompleted) {
                        case (true, false, false):
                            isExceeded = true
                            return
                        case (true, true, true):
                            isExceeded = true
                            return
                        case (false, true, true):
                            isExceeded = true
                            return
                        default:
                            break
                        }
                        
                        data.completed.append(identifier)
                        data.takenGold.append(identifier)
                    case true:
                        var linkingContent: [String] = []
                        additional.forEach { content in
                            if content.type >= 40 && content.takenGold.contains(identifier) {
                                numberOfCompleted += 1

                                if linkingContent.contains(content.link) && content.link != "" {
                                    numberOfCompleted -= 1
                                } else if content.link != "" {
                                    linkingContent.append(content.link)
                                }
                            }
                        }
                        
                        let link = additional.filter { content in
                            return content.type >= 40 && content.takenGold.contains(identifier) && content.link != ""
                        }.map { content in content.link }
                        
                        let gate = additional.filter { content in
                            return content.type >= 40 && content.takenGold.contains(identifier) && content.gate != ""
                        }.map { content in content.gate }

                        let isLinkingContentCompleted = link.contains(data.link)
                        let isSameGateContentCompleted = gate.contains(data.gate)

                        switch (numberOfCompleted >= self.numberOfLimitCompleted, isLinkingContentCompleted, isSameGateContentCompleted) {
                        case (true, false, false):
                            isExceeded = true
                        case (true, true, true):
                            isExceeded = true
                        case (false, true, true):
                            isExceeded = true
                        default:
                            break
                        }
                        
                        if isExceeded {
                            data.completed.append(identifier)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)

                            let includeMember = RealmManager.shared.read(Member.self, identifier: identifier).first
                            cell.data = showExcludedMember ? filter : includeMember
                            cell.completed = data.completed.contains(identifier)
                        } else {
                            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "골드 보상 획득".localized, style: .default, handler: { action in
                                RealmManager.shared.update {
                                    data.completed.append(identifier)
                                    data.takenGold.append(identifier)
                                }
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
                            }))

                            alert.addAction(UIAlertAction(title: "골드 보상 미획득".localized, style: .default, handler: { action in
                                RealmManager.shared.update {
                                    data.completed.append(identifier)
                                }
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
                            }))
                            
                            alert.addAction(UIAlertAction(title: "취소".localized, style: .destructive, handler: nil))

                            self.target?.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    data.completed.append(identifier)
                    data.takenGold.append(identifier)
                }
            }
        }
        
        
        if isExceeded { return }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)

        let includeMember = RealmManager.shared.read(Member.self, identifier: identifier).first
        cell.data = showExcludedMember ? filter : includeMember
        cell.completed = data.completed.contains(identifier)
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
