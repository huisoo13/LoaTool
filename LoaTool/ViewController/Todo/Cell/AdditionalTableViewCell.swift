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
            
            addObserver()
            
            iconImageView.image = UIImage(named: "content.icon.\(data.icon)")
            nameLabel.text = data.title
            nameLabel.textColor = data.weekday.contains(DateManager.shared.currentWeekday()) ? .label : .systemRed
            
            updatedView(data)

            showCharacterList = nil
            collectionView.reloadData()
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
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        setupView()
        setupCollectionView()
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
}

extension AdditionalTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(UINib(nibName: "AdditionalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdditionalCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data?.included.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = self.data,
              let identifier = data.included[safe: indexPath.item] else { return .zero }
        
        let member = RealmManager.shared.read(Member.self, identifier: identifier).first
        let count = member?.name.count ?? 4
        let width = max(40, CGFloat(10 * count))
        
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AdditionalCollectionViewCell,
              let data = self.data,
              let identifier = data.included[safe: indexPath.item] else { return }

        cell.completed = data.completed.contains(identifier)
        
        if data.type >= 40 {
            guard let additional = RealmManager.shared.readAll(Todo.self).first?.additional else { return }
            
            var numberOfCompleted = 0
            additional.forEach { content in
                if content.type >= 40 && content.completed.contains(identifier) {
                    numberOfCompleted += 1
                }
            }
            
            cell.nameLabel.textColor = numberOfCompleted >= self.numberOfLimitCompleted && !data.completed.contains(identifier)
            ? .systemRed
            : ( numberOfCompleted >= (self.numberOfLimitCompleted - 1) && !data.completed.contains(identifier) ? .systemPurple : .label)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdditionalCollectionViewCell", for: indexPath) as! AdditionalCollectionViewCell
        
        if let data = self.data,
           let identifier = data.included[safe: indexPath.item] {
            let member = RealmManager.shared.read(Member.self, identifier: identifier).first
            cell.data = member
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
                    additional.forEach { content in
                        if content.type >= 40 && content.completed.contains(identifier) {
                            numberOfCompleted += 1
                        }
                    }
                    
                    if numberOfCompleted >= self.numberOfLimitCompleted {
                        isExceeded = true
                        return
                    }
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
    
    func addObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
    
    @objc func reloadData(_ sender: NSNotification) {
        collectionView.reloadData()
        
        guard let data = self.data else { return }
        updatedView(data)
    }
    
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
            
            data.included.forEach { identifier in
                if data.completed.contains(identifier) { return }
                
                var numberOfCompleted = 0
                additional.forEach { content in
                    if content.type >= 40 && content.completed.contains(identifier) {
                        numberOfCompleted += 1
                    }
                }
                
                if numberOfCompleted >= 3 { numberOfOverflow += 1 }
            }
        }

        return numberOfOverflow
    }
}
