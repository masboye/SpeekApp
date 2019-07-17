//
//  History.swift
//  SpeekApp
//
//  Created by William Inx on 15/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

class History {
    
    var recordingTitle:String
    var recordingTopic:String
    var recordingDate:Date
    
    init(title:String,topic:String,date:Date) {
        recordingTitle = title
        recordingTopic = topic
        recordingDate = date
    }
}
