//
//  ImagePickerViewController+UITableView.swift
//  ImagePickerViewControllerSample
//
//  Created by Trading Taijoo on 2022/04/26.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

extension ImagePickerViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        albumView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: albumView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: albumView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: albumView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: albumView.trailingAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "ImagePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "ImagePickerTableViewCell")
        
        albums = viewModel.getAlbumList()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "앨범 목록"
        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagePickerTableViewCell", for: indexPath) as! ImagePickerTableViewCell
        
        let data = albums[indexPath.row]
        cell.data = data
        cell.isSelectedAlbum = selectedAlbum?.identifier == data.identifier
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = albums[indexPath.row]
        if selectedAlbum?.identifier == data.identifier { return }
        
        viewModel.configure(data.identifier)
        selectedAlbum = data
        
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.albumView.isHidden = !self.albumView.isHidden
        })
        
        guard let button = self.navigationItem.titleView as? UIButton else { return }
        button.setTitle("\(data.title) ▾", for: .normal)
        
        let width = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        button.frame = CGRect(origin: .zero, size: CGSize(width: width, height: 500))
    }
}
