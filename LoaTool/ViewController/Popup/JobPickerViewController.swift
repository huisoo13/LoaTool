//
//  JobPickerViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/13.
//

import UIKit

protocol JobPickerViewDelegate {
    func pickerView(_ symbol: UIImage, job: String, didSelectItemAt index: Int)
}

class JobPickerViewController: UIViewController, Storyboarded {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var coordinator: AppCoordinator?
    var delegate: JobPickerViewDelegate?
    
    let numberOfItemInLine: Int = 4
    let minimumSpacing: CGFloat = 10
    let contentInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("\(#fileID): \(#function)")

        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debug("\(#fileID): \(#function)")
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        coordinator?.dismiss(animated: true)
    }
}

extension JobPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = contentInset
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        String.job().count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (UIScreen.main.bounds.width - (minimumSpacing * CGFloat(numberOfItemInLine - 1)) - (contentInset.left * 2)) / CGFloat(numberOfItemInLine)
        
        return CGSize(width: width, height: width)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let job = String.job()[indexPath.row]

        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        
        let imageView = UIImageView()
        imageView.image = job.getSymbol()
        imageView.tintColor = .black
        
        cell.contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let job = String.job()[indexPath.row]
        
        delegate?.pickerView(job.getSymbol(), job: job, didSelectItemAt: indexPath.row)
        coordinator?.dismiss(animated: true)
    }
}


