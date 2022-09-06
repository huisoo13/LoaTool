//
//  OpenSourceLibraryViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/18.
//

import UIKit

struct OpenSource {
    var title: String
    var license: String
    var permission: String
    var limitation: String
    var condition: String
}

class OpenSourceLibraryViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: AppCoordinator?
    
    var datas: [OpenSource] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupData()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setupData() {
        datas = [OpenSource(title: "Alamofire",
                            license: "MIT License",
                            permission:
                                """
                                Commercial use
                                Modification
                                Distribution
                                Private use
                                """,
                            limitation:
                                """
                                Liability
                                Warranty
                                """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "SwiftyJSON",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "Kingfisher",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "SwiftSoup",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "RealmSwift",
                            license: "Apache License 2.0",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "Hero",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 /*
                 OpenSource(title: "BouncyLayout",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "AMPopTip",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "MIBlurPopup",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                  */
                 OpenSource(title: "TGPControls",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 /*
                 OpenSource(title: "CHIPageControl/Jaloro",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                  */
                 OpenSource(title: "SwiftReorder",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           ),
                 OpenSource(title: "CRRefresh",
                            license: "MIT License",
                            permission:
                                 """
                                 Commercial use
                                 Modification
                                 Distribution
                                 Private use
                                 """,
                            limitation:
                                 """
                                 Liability
                                 Warranty
                                 """,
                            condition: "License and copyright notice"
                           )
        ]
    }
}

extension OpenSourceLibraryViewController {
    fileprivate func setupNavigationBar() {
        setTitle("오픈 소스 라이브러리".localized, size: 20)
    }

}

extension OpenSourceLibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "OpenSourceLibraryTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenSourceLibraryTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        
        header.label.text = "목록"

        header.typeView.isHidden = true
        header.button.isHidden = true
        
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSourceLibraryTableViewCell", for: indexPath) as! OpenSourceLibraryTableViewCell
        
        cell.data = datas[safe: indexPath.row]
        
        return cell
    }
}
