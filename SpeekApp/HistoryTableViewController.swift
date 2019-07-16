//
//  HistoryTableViewController.swift
//  SpeekApp
//
//  Created by William Inx on 15/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    var filteredData:[History]?
    var passedData:History?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for x in 1...10{
            filteredData?.append(History(title: "title \(x)", topic: "topic \(x)", date: Date()))
        }
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
