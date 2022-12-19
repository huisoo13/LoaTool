//
//  RecipeViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/12.
//

import UIKit
import Kingfisher

class RecipeViewController: UIViewController, Storyboarded {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentsView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var materialImageView: UIImageView!
    @IBOutlet weak var materialFeeLabel: UILabel!
    @IBOutlet weak var materialPriceLabel: UILabel!
    @IBOutlet weak var materialPriceAndCostLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productFeeLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet var profitAndLossLabels: [UILabel]!
    @IBOutlet var accentViews: [UIView]!
    
    weak var coordinator: AppCoordinator?
    
    var data: Recipe?
    var reducedCrafingFeeAtPercent: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupGestureRecognizer()
        setupTableView()
        updateContentView()
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
                
        accentViews.forEach { view in
            view.layer.cornerRadius = 8
        }
    }
    
    func updateContentView() {
        guard let data = data else { return }
        
        if let url = URL(string: data.product.url) {
            imageView.kf.setImage(with: url)
            imageView.backgroundColor = data.product.grade.getColor().darker(by: 50)
                        
            productImageView.kf.setImage(with: url)
            productImageView.backgroundColor = data.product.grade.getColor().darker(by: 50)
        }
        
        nameLabel.text = data.name
        goldLabel.text = "\(data.product.currentMinPrice)"
        dateLabel.text = DateManager.shared.convertDateFormat(data.product.date, originFormat: "yyyy-MM-dd HH:mm:ss", newFormat: "yyyy-MM-dd HH:mm")
        
        let numberOfMaterial: Int = data.cost == 0 ? data.material.count : (data.material.count) + 1
        heightAnchor.constant = CGFloat(numberOfMaterial * 32 + 8)
        
        if let url = URL(string: "https://cdn-lostark.game.onstove.com/EFUI_IconAtlas/Use/Use_2_9.png") {
            materialImageView.kf.setImage(with: url)
            materialImageView.backgroundColor = .white.darker(by: 50)
        }
        
        let cost = floor(Double(data.cost) * (1.0 - reducedCrafingFeeAtPercent))
        let material = calculator(onPriceAndFeeAt: data.material)
        
        materialFeeLabel.text = String(format: "%.2f", material.fee)
        materialPriceLabel.text = String(format: "%.2f", material.price)
        materialPriceAndCostLabel.text = String(format: "%.2f", material.price + cost)

        let fee = Int(ceil(Double(data.product.currentMinPrice) * 0.05)) * data.bundleCount / data.product.bundleCount
        let price = data.product.currentMinPrice * data.bundleCount / data.product.bundleCount
        
        productNameLabel.text = data.name + " X\(data.bundleCount)"
        productFeeLabel.text = String(fee)
        productPriceLabel.text = String(price)
        
        profitAndLossLabels.enumerated().forEach { i, label in
            switch i {
            case 0:
                label.text = (material.price + cost) < Double(price - fee) ? "이득" : "손해"            // 총 제작비 < 결과물 판매해서 번돈
            case 1:
                label.text = (material.price + cost) < Double(price) ? "이득" : "손해"                  // 총 제작비 < 결과물을 산 돈
            case 2:
                label.text = (material.price - material.fee) < Double(price - fee) - cost ? "이득" : "손해"    // 재료를 팔아서 번돈 < 결과물을 팔아서 번돈 - 소모한 돈
            case 3:
                label.text = (material.price - material.fee) < Double(price) - cost ? "이득" : "손해"           // 재료를 팔아서 구할 수 있는 양 < 제작한 양
            default:
                break
            }
            
            label.textColor = label.text == "이득" ? .custom.itemGrade2 : .custom.qualityRed
        }
    }
    
    func setupGestureRecognizer() {
        backgroundView.addGestureRecognizer { _ in
            self.coordinator?.dismiss(animated: true)
        }
        
        contentsView.addGestureRecognizer(with: .longPress) { _ in
            let image = self.rendering()
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func calculator(onPriceAndFeeAt materials: [Material?]?) -> (price: Double, fee: Double) {
        guard let materials = materials else { return (0, 0) }
        
        var price: Double = 0
        var fee: Double = 0
        
        materials.forEach { material in
            guard let material = material else { return }

            price += Double(material.currentMinPrice) * Double(material.neededQuantity) / Double(material.bundleCount)
            
            let bundleFee = material.currentMinPrice == 1 ? 0 : Double(material.currentMinPrice) * 0.05
            fee += ceil(bundleFee) * Double(material.neededQuantity) / Double(material.bundleCount)
        }

        return (price, fee)
    }
    
    func rendering() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: contentsView.bounds)
        return renderer.image { rendererContext in
            contentsView.layer.render(in: rendererContext.cgContext)
        }
    }
}

extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MaterialTableViewCell", bundle: nil), forCellReuseIdentifier: "MaterialTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        
        let numberOfMaterial: Int = data.cost == 0 ? data.material.count : (data.material.count) + 1
        return numberOfMaterial
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MaterialTableViewCell", for: indexPath) as! MaterialTableViewCell
        
        if let data = data?.material[safe: indexPath.row] {
            cell.data = data
        } else {
            let cost = floor(Double(data?.cost ?? 0) * (1.0 - reducedCrafingFeeAtPercent))
            cell.data = data?.cost(of: Int(cost))
        }

        return cell
    }
}
