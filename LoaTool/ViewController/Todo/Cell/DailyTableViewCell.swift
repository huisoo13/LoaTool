//
//  DailyTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/30.
//

import UIKit
import TGPControls

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var camelLabel: TGPCamelLabels!
    @IBOutlet weak var slider: TGPDiscreteSlider!
    
    weak var coordinator: AppCoordinator?

    var cellSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 168)
    let minimumLineSpacing: CGFloat = 8
    
    var showCompleteCharacter: Bool = UserDefaults.standard.bool(forKey: "showCompleteCharacter")
    var isCompleted: Bool = false
    
    var data: [Member]? {
        didSet {
            guard let _ = data else { return }
            
            setupData()
            setupView()
            setupSlider()
        }
    }
    
    var filter: [Member] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupData()
        setupView()
        setupSlider()
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setupData() {
        guard let data = showCompleteCharacter
                ? self.data
                : self.data?.filter({ member in
                    let isCompleted = member.contents.map { $0.value >= $0.maxValue || $0.minBonusValue > $0.originBonusValue }.contains(false)
                    return isCompleted
                }) else { return }
        
        filter = data.count == 0 ? Array(self.data ?? data) : data
        isCompleted = data.count == 0

    }
    
    fileprivate func setupView() {
        selectionStyle = .none
        
        guard let data = self.data?.filter({ member in
                    let isCompleted = member.contents.map { $0.value >= $0.maxValue || $0.minBonusValue > $0.originBonusValue }.contains(false)
                    return isCompleted
                }) else { return }
        
        let count = data.count
        
        label.attributedText = count != 0
        ? "\(count)개의 캐릭터가 남았습니다."
            .attributed(of: "\(count)개", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
            .addAttribute(of: "\(count)개", key: .foregroundColor, value: UIColor.custom.textBlue)
        : "모든 캐릭터를 완료했습니다."
            .attributed(of: "모든 캐릭터를 완료했습니다.", key: .font, value: UIFont.systemFont(ofSize: 12, weight: .semibold))
            .addAttribute(of: "모든 캐릭터를 완료했습니다.", key: .foregroundColor, value: UIColor.systemPurple)
        
        button.setTitle(showCompleteCharacter ? "미완료 캐릭터만 보기" : "모든 캐릭터 보기", for: .normal)
                
        collectionView.reloadData()
        if !isCompleted {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    fileprivate func setupSlider() {
        
        camelLabel.names = filter.count != 0 ? filter.map { $0.name } : [" ", " ", " "]
        
        slider.tickCount = camelLabel.names.count <= 1 ? 3 : camelLabel.names.count
        slider.ticksListener = camelLabel
        
        camelLabel.value = !(camelLabel.names.count <= 1) ? 0 : 1
        slider.value = !(camelLabel.names.count <= 1) ? 0 : 1
        slider.isUserInteractionEnabled = !(camelLabel.names.count <= 1)

        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    @objc func valueChanged(_ sender: TGPDiscreteSlider) {
        collectionView.scrollToItem(at: IndexPath(item: Int(sender.value), section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func updateData(_ sender: UIButton) {
        showCompleteCharacter = !showCompleteCharacter
        
        UserDefaults.standard.set(showCompleteCharacter, forKey: "showCompleteCharacter")
        button.setTitle(showCompleteCharacter ? "미완료 캐릭터만 보기" : "모든 캐릭터 보기", for: .normal)

        setupData()
        setupView()
        setupSlider()
    }
}


extension DailyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView.register(UINib(nibName: "DailyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DailyCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize = CGSize(width: collectionView.bounds.width - 32, height: 168)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCollectionViewCell", for: indexPath) as! DailyCollectionViewCell
                
        cell.data = filter[safe: indexPath.row]
        cell.coordinator = coordinator
        return cell
    }
}

extension DailyTableViewCell: UIScrollViewDelegate {
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

        if 0..<camelLabel.names.count ~= index {
            camelLabel.value = UInt(index)
            slider.value = CGFloat(index)
        }
        
        targetContentOffset.pointee = CGPoint(x: (CGFloat(index) * cellWidthIncludingSpacing) - (minimumLineSpacing * 2), y: 0)
    }
}
