//
//  SummaryViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/14.
//

import UIKit
import Vision
import Kingfisher

class SummaryViewController: UIViewController, Storyboarded {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentsView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var guildLabel: UILabel!
    @IBOutlet weak var guildMasterImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var expeditionLabel: UILabel!
    
    @IBOutlet var abilityViews: [UIView]!
    
    @IBOutlet weak var jobImageView: UIImageView!
    
    @IBOutlet weak var weaponLevelLabel: UILabel!
    @IBOutlet weak var weaponQualityLabel: UILabel!
    @IBOutlet weak var weaponLabel: UILabel!
    
    @IBOutlet weak var armorLevelLabel: UILabel!
    @IBOutlet weak var armorQualityLabel: UILabel!
    
    @IBOutlet weak var setTypeLabel: UILabel!
    @IBOutlet weak var setTypeSubLabel: UILabel!
    
    @IBOutlet weak var maxSkillPointLabel: UILabel!
    @IBOutlet weak var usedSkillPointLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var cardLabel: UILabel!
    
    @IBOutlet weak var tripodLabel: UILabel!
    @IBOutlet weak var tripodDescriptionLabel: UILabel!
    
    @IBOutlet weak var gemBarChartView: GemBarChartView!
    
    @IBOutlet weak var accentView: UIView!
    
    @IBOutlet weak var tripleView: TripleDivisionCircleView!
    weak var coordinator: AppCoordinator?
    
    var data: Character?
    var text: String?
    var viewModel = CharacterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCollectionView()
        setupData()
        updateContentView()
        setupGestureRecognizer()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupView()
    }
        
    func setupView() {
        contentsView.subviews.first?.layer.borderColor = UIColor.label.cgColor
        contentsView.subviews.first?.layer.borderWidth = 0.5
        
        contentsView.subviews.forEach { $0.isUserInteractionEnabled = false }
        
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.layer.borderWidth = 0.5
        
        accentView.layer.cornerRadius = 8
        
        jobImageView.superview?.layer.cornerRadius = (jobImageView.superview?.bounds.height)! / 2
        jobImageView.superview?.layer.borderColor = UIColor.label.cgColor
        jobImageView.superview?.layer.borderWidth = 0.5
        
        abilityViews.enumerated().forEach { i, view in
            guard let barChartView = view.subviews[safe: 1] else { return }
            barChartView.layer.cornerRadius = 2
        }
    }
    
    func setupData() {
        guard let text = self.text else { return }
        
        setupViewModelObserver()
        viewModel.configure(self, search: text, isMain: false, showIndicator: true)
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            self.data = result
            self.updateContentView()
        }
    }
    
    func updateContentView() {
        guard let data = self.data else { return }
        
        if let info = data.info {
            nameLabel.text = info.name.components(separatedBy: " ").last ?? ""
            serverLabel.text = info.server
            guildLabel.text = info.guild != "-" ? "@\(info.guild)" : ""
            guildLabel.textColor = .custom.qualityGreen.darker(by: 50)
            guildMasterImageView.isHidden = !info.isMaster
            levelLabel.text = "Lv. \(info.level)"
            expeditionLabel.text = "\(info.expedition)"
            
            jobImageView.image = info.job.getSymbol()
            setupImageView(with: info.imageURL)
        }
        
        if let stats = data.stats {
            abilityViews.enumerated().forEach { i, view in
                guard let label = view.subviews.last as? UILabel,
                      let barChartView = view.subviews[safe: 1] else { return }
                
                let multiplier: CGFloat
                
                switch i {
                case 0:
                    label.text = "\(stats.critical)"
                    multiplier = CGFloat(stats.critical) / 1800.0
                case 1:
                    label.text = "\(stats.specialization)"
                    multiplier = CGFloat(stats.specialization) / 1800.0
                case 2:
                    label.text = "\(stats.swiftness)"
                    multiplier = CGFloat(stats.swiftness) / 1800.0
                case 3:
                    label.text = "\(stats.domination)"
                    multiplier = CGFloat(stats.domination) / 1800.0
                case 4:
                    label.text = "\(stats.endurance)"
                    multiplier = CGFloat(stats.endurance) / 1800.0
                case 5:
                    label.text = "\(stats.expertise)"
                    multiplier = CGFloat(stats.expertise) / 1800.0
                default:
                    label.text = "0"
                    multiplier = 0
                }
                

                barChartView.subviews.forEach { $0.removeFromSuperview() }
                
                let barView = UIView()
                
                let width = multiplier * barChartView.bounds.width
                barView.frame = CGRect(x: 0, y: 0, width: width, height: 5)
                
                switch multiplier {
                case 1..<2:
                    barView.backgroundColor = .custom.qualityOrange
                case (0.85)..<1:
                    barView.backgroundColor = .custom.qualityPurple
                case (0.6)..<0.85:
                    barView.backgroundColor = .custom.qualityBlue
                case (0.3)..<0.6:
                    barView.backgroundColor = .custom.qualityGreen
                case (0.1)..<0.3:
                    barView.backgroundColor = .custom.qualityYellow
                case 0...0.1:
                    barView.backgroundColor = .custom.qualityRed
                default:
                    break
                }
                
                barChartView.clipsToBounds = true
                barChartView.addSubview(barView)
            }
            
            if let etc = data.etc,
               let weapon = data.equip[safe: 0],
               let armor = Array(data.equip)[safe: 1..<6] {
                
                weaponLabel.text = Lostark.shared.weapon(weapon)
                weaponLevelLabel.text = "\(weapon.level)"
                weaponQualityLabel.text = "품질 \(weapon.quality)"
                
                armorLevelLabel.text = "\(Int(Double(armor.map({ $0.level }).reduce(0, +)) / Double(armor.count)))"
                armorQualityLabel.text = String(format: "품질 %0.1f", Double(armor.map({ $0.quality }).reduce(0, +)) / Double(armor.count))
                                
                setTypeLabel.text = etc.setType.components(separatedBy: "\n").first ?? ""
                setTypeSubLabel.text = etc.setType.components(separatedBy: "\n").last ?? ""
                
                maxSkillPointLabel.text = "\(etc.maxSkillPoint)"
                usedSkillPointLabel.text = "(\(etc.usedSkillPoint))"
            }
            
            let card = Array(data.card)
            cardLabel.text = convertCardToString(card) + " "
            
            
            var sum = 0
            var selectedTripodCount = 0
            var upgradeTripodCount = 0
            var maxLevelIsOneTripodCount = 0
            
            let skills = Array(data.skill)
            skills.forEach { skill in
                if let tripod1 = skill.tripod1 {
                    selectedTripodCount += 1
                    
                    let level = Int((tripod1.components(separatedBy: "레벨 ").last ?? "").components(separatedBy: " ").first ?? "") ?? 0
                    let isMaximum = tripod1.contains("(최대)")

                    if level > 1 {
                        sum += level
                        upgradeTripodCount += 1
                    }
                    
                    if level == 1 && isMaximum { maxLevelIsOneTripodCount += 1 }
                }
                
                if let tripod2 = skill.tripod2 {
                    selectedTripodCount += 1
                    
                    let level = Int((tripod2.components(separatedBy: "레벨 ").last ?? "").components(separatedBy: " ").first ?? "") ?? 0
                    let isMaximum = tripod2.contains("(최대)")

                    if level > 1 {
                        sum += level
                        upgradeTripodCount += 1
                    }
                    
                    if level == 1 && isMaximum { maxLevelIsOneTripodCount += 1 }
                }

                if let tripod3 = skill.tripod3 {
                    selectedTripodCount += 1
                    
                    let level = Int((tripod3.components(separatedBy: "레벨 ").last ?? "").components(separatedBy: " ").first ?? "") ?? 0
                    let isMaximum = tripod3.contains("(최대)")
                    
                    if level > 1 {
                        sum += level
                        upgradeTripodCount += 1
                    }
                    
                    if level == 1 && isMaximum { maxLevelIsOneTripodCount += 1 }
                }
            }
            
            if upgradeTripodCount == 18 {
                let level = Double(sum) / Double(18)
                tripodLabel.text = String(format: "%0.2f", level)
                
                let description = "(최대 \(18 * 5) 레벨 중 \(sum) 레벨 적용)"
                tripodDescriptionLabel.text = description
            } else if upgradeTripodCount < 18 && (selectedTripodCount - maxLevelIsOneTripodCount) <= 18 {
                let selectableTripodCount = selectedTripodCount - maxLevelIsOneTripodCount

                let level = Double(sum + (selectableTripodCount - upgradeTripodCount)) / Double(selectableTripodCount)
                tripodLabel.text = String(format: "%0.2f", level)
                                   
                let description = "(최대 \(selectableTripodCount * 5) 레벨 중 \(sum + (selectableTripodCount - upgradeTripodCount)) 레벨 적용)"
                tripodDescriptionLabel.text = description
            } else if upgradeTripodCount < 18 && (selectedTripodCount - maxLevelIsOneTripodCount) > 18 {
                let level = Double(sum + (18 - upgradeTripodCount)) / Double(18)
                tripodLabel.text = String(format: "%0.2f", level)
                
                let description = "(최대 \(18 * 5) 레벨 중 \((sum + (18 - upgradeTripodCount))) 레벨 적용)"
                tripodDescriptionLabel.text = description
            }
            
            gemBarChartView.values = Array(data.gem).sorted(by: { ($0.level, $1.title) > ($1.level, $0.title) })
        }
        
        collectionView.reloadData()
    }
    
    fileprivate func convertCardToString(_ data: [Card]) -> String {
        let title = data.map { card in
            card.title.replacingOccurrences(of: " [0-9]+세트", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "각성합계", with: "", options: .regularExpression)
            .replacingOccurrences(of: "_ ", with: "", options: .regularExpression)
            .replacingOccurrences(of: "_", with: "", options: .regularExpression)
        }
        
        let card = data.map { card in
            return card.title.replacingOccurrences(of: " [0-9]+세트", with: "_", options: .regularExpression).components(separatedBy: "_").first ?? ""
        }

        var string = ""
        Set(card).sorted(by: { $0 < $1 }).forEach { card in
            if title.contains(card) {
                guard let data = title.filter({ $0.contains(card)}).sorted(by: { ($0.count, $0) < ($1.count, $1) }).last else { return }
                string += "\(data)\n"
            }
        }
        
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    
    func setupGestureRecognizer() {
        backgroundView.addGestureRecognizer { _ in
            self.coordinator?.dismiss(animated: true)
        }
        
        contentsView.addGestureRecognizer(with: .longPress) { _ in
            let image = self.rendering()
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                activityViewController.popoverPresentationController?.permittedArrowDirections = []
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func rendering() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: contentsView.bounds)
        return renderer.image { rendererContext in
            contentsView.layer.render(in: rendererContext.cgContext)
        }
    }
}

extension SummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 32)
        collectionView.register(UINib(nibName: "EngravingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EngravingCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = self.data?.engrave?.effect.components(separatedBy: "\n")
        return data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 64
        return CGSize(width: width / 2, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EngravingCollectionViewCell", for: indexPath) as! EngravingCollectionViewCell
        
        let data = self.data?.engrave?.effect.components(separatedBy: "\n")
        cell.data = data?[safe: indexPath.item]
        
        return cell
    }
}


// MARK: - Vision
extension SummaryViewController {
    func setupImageView(with urlString: String, placeholder: UIImage? = UIImage(), size: CGSize = CGSize(width: 512, height: 512)) {
        if let url = URL(string: urlString) {
            let processor = DownsamplingImageProcessor(size: size) |> RoundCornerImageProcessor(cornerRadius: 0)
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            imageView.kf.indicatorType = .activity
            
            DispatchQueue.main.async {
                self.imageView.kf.setImage(with: resource, placeholder: placeholder, options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .transition(.fade(0.5))
                ], completionHandler: { result in
                    switch result {
                    case .success(let value):
                        let image = value.image
                        self.detectFaceLandmarksRequest(with: image)
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                })
            }
        }
    }
    
    // MARK: - VNDetectFaceRectanglesRequest
    func detectFaceLandmarksRequest(with image: UIImage?) {
        guard let cgImage = image?.cgImage else { return }

        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(results, willCrop: image)
                } else {
                    self.imageView.image = image
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .downMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation], willCrop image: UIImage?) {
        let faceBouningBoxes = observedFaces.map({ observedFace in
            return observedFace
        })
                                                 
        faceBouningBoxes.forEach { faceObservation in
            guard let image = image else { return }
                        
            let faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(faceObservation.boundingBox, Int(image.size.width ), Int(image.size.height))
            let croppedCGImage = image.cgImage?.cropping(to: CGRect(x: (faceBoundingBoxOnScreen.minX - faceBoundingBoxOnScreen.width) * image.scale,
                                                                   y: (faceBoundingBoxOnScreen.minY - faceBoundingBoxOnScreen.height) * image.scale,
                                                                   width: 3 * faceBoundingBoxOnScreen.width * image.scale,
                                                                   height: 4 * faceBoundingBoxOnScreen.height * image.scale))
            
            let croppedImage = UIImage(cgImage: croppedCGImage!)

            self.imageView.image = croppedImage
        }
    }
}
