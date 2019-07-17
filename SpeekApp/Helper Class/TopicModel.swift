//
//  TopicModel.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 16/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

class TopicModel {
    var title: String
    var recording: RecordingModel
    
    init() {
        self.title = ""
        self.recording = RecordingModel()
    }
    
    init(title: String, recording: RecordingModel) {
        self.title = title
        self.recording = recording
    }
}

