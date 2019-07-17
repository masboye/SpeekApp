//
//  HistoryTableViewController.swift
//  SpeekApp
//
//  Created by William Inx on 15/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

extension UIViewController{
    func HideKbd() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKbd))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKbd() {
        view.endEditing(true)
    }
}

class HistoryTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    var filteredData:[History]?
    var passedData:History?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKbd()
        //filteredData = mainData
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Fetch Data from Core Data
        return filteredData?.count ?? 0
    }
    
    
}
