//
//  CharacterViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/28.
//

import UIKit

class CharacterViewController: UIViewController, Storyboarded {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var button: UIButton!
    
    weak var coordinator: AppCoordinator?
    
    var isMainCharacter: Bool = true
    var showIndicator: Bool = true
    var text: String = User.shared.name
    
    let viewModel: CharacterViewModel = CharacterViewModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        setupNavigationBar()
        setupViewModelObserver()
    }
    
    func setupData() {
        if isMainCharacter {
            text = User.shared.name
            viewModel.result.value = RealmManager.shared.readAll(Character.self).last
        }
        
        collectionView.isHidden = isMainCharacter && text == ""
        helpView.isHidden = !(isMainCharacter && text == "")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.reloadData()
        }, completion: { _ in
            self.collectionView.reloadData()
        })
    }
    
    fileprivate func setupViewModelObserver() {
        viewModel.result.bind { result in
            self.collectionView.reloadData()
            
            guard let name = result?.info?.name, name != "" else { return }
            self.helpView.isHidden = true
        }
        
        
        if isMainCharacter && text == "" { return }
        viewModel.configure(self, search: text, isMain: isMainCharacter, showIndicator: showIndicator)
        showIndicator = false
    }
    
    @IBAction func moveToMainCharacterViewControllerAction(_ sender: Any) {
        coordinator?.pushToMainCharacterViewController(animated: true)
    }
}

extension CharacterViewController: CharacterListDelegate {
    fileprivate func setupNavigationBar() {
        setTitle("캐릭터 정보".localized, size: 20)
        
        let list = UIBarButtonItem(image: UIImage(systemName: "list.dash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)), style: .plain, target: self, action: #selector(selectedBarButtonItem(_:)))
        addRightBarButtonItems([list])
    }
    
    @objc func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        let list = viewModel.result.value?.info?.memberList
            .components(separatedBy: " ")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ $0 != "" }) ?? []
        coordinator?.presentToCharacterListViewController(self, list: list, animated: true)
    }

    func character(_ server: String, didSelectRowAt name: String) {
        viewModel.configure(self, search: name, isMain: isMainCharacter, showIndicator: true)
    }
}

extension CharacterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.contentInset = .zero
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(UINib(nibName: "CharacterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CharacterCollectionViewCell")
        collectionView.register(UINib(nibName: "ImageViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.result.value != nil ? 3 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width > 375 * 3
        ? collectionView.bounds.width / 3
        : (collectionView.bounds.width > 375 * 2
           ? collectionView.bounds.width / 2
           : collectionView.bounds.width)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = collectionView.bounds.width > 375 * 3
        ? 10
        : (collectionView.bounds.width > 375 * 2
           ? 10
           : .zero)
        
        return spacing
        // .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = collectionView.bounds.width > 375 * 3
        ? 10
        : (collectionView.bounds.width > 375 * 2
           ? 10
           : .zero)
        
        return spacing
        // .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionViewCell", for: indexPath) as! ImageViewCollectionViewCell
                    
            cell.profileURL = viewModel.result.value?.info?.imageURL

            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCollectionViewCell", for: indexPath) as! CharacterCollectionViewCell
                    
            cell.type = indexPath.row
            cell.data = viewModel.result.value

            return cell
        }
    }
}
