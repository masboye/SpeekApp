//
//  HistoryTableViewController.swift
//  SpeekApp
//
//  Created by William Inx on 15/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var historyTable: UITableView!
    
    var filteredData:[TopicModel]!
    var passedData:TopicModel!
    var mainData:[TopicModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()
        mainData = getData()
        filteredData = mainData
        searchBar.delegate = self
        historyTable.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell",for: indexPath)
        
        let recordingTitle:String
        let recordingDate:Date
        let recordingTopic:String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        recordingTitle = filteredData[indexPath.row].recording.title
        recordingDate = filteredData[indexPath.row].recording.date
        recordingTopic = filteredData[indexPath.row].title
        
        cell.textLabel?.text = recordingTitle
        cell.detailTextLabel?.text = recordingTopic + " : " + dateFormatter.string(from: recordingDate)
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? mainData : mainData.filter({ (topicModel) -> Bool in
            return topicModel.recording.title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        tableView.reloadData()
    }
    
    
    
    func getData() -> [TopicModel] {
        let cdh: CoreDataHelper = CoreDataHelper()
        
        let topics: [Topic] = cdh.fetch(entityName: "Topic")
        var topicModels:[TopicModel] = [TopicModel()]
        
        for topic in topics {
            //print(topic.title)
            let recordings:[Recording] = topic.topicToRec?.allObjects as! [Recording]
            
            for recording in recordings {
                
                //print(recording.title)
                let topicModel = TopicModel(title: topic.title!, recording: RecordingModel(title: recording.title!, date: recording.date!, video: VideoModel(title: recording.recToVid!.title!, filePath: recording.recToVid!.filepath!, eyeContactLost: recording.recToVid!.eyecontactlost, attention: recording.recToVid!.attention, smileDuration: recording.recToVid!.smileduration)))
                
                topicModels.append(topicModel)
            }
        }
        topicModels.remove(at: 0)
        return topicModels
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSearchText()
        reloadTable()
    }
    
    func reloadTable(){
        removeSearchText()
        filteredData = mainData
        tableView.reloadData()
    }
    
    func removeSearchText(){
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}
