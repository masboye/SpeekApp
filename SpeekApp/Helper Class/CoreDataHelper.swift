//
//  ModelCore.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 16/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper{
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func saveTopic(topicModel: TopicModel){
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else{return}
        
        let topicDatas: [Topic] = fetch(entityName: "Topic")
        var isSameTopic = false
        var topic:Topic
        var topicTemp:Topic?
        
        let recording = Recording(context: managedContext)
        recording.date = topicModel.recording.date
        recording.title = topicModel.recording.title
        
        let video = Video(context: managedContext)
        video.title = topicModel.recording.video.title
        video.attentionleft = topicModel.recording.video.attentionLeft
        video.attentionright = topicModel.recording.video.attentionRight
        video.attentioncenter = topicModel.recording.video.attentionCenter
        video.eyecontactlost = topicModel.recording.video.eyeContactLost
        video.smileduration = topicModel.recording.video.smileDuration
        video.filepath = topicModel.recording.video.filePath
        
        for topicData in topicDatas {
            if topicData.title == topicModel.title {
                isSameTopic = true
                topicTemp = topicData
                break;
            }
        }
        
        if isSameTopic {
            if let topic = topicTemp {
                topic.addToTopicToRec(recording)
                recording.recToVid = video
            }
        }
        else {
            topic = Topic(context: managedContext)
            topic.title = topicModel.title
            topic.addToTopicToRec(recording)
            recording.recToVid = video
        }
        
        do {
            try managedContext.save()
            print("Success saving data")
        }
        catch {
            print("Error saving data")
        }
        
    }
    func delete(){
        
    }
    
    func fetch<T>(entityName: String) -> [T] {
        var result: [T] = []
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return result}
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            result = try managedContext.fetch(request) as! [T]
            print("Success fetching data")
        } catch  {
            result = []
            print("Error : failed to fetch data")
        }
        
        return result
    }
    
}
