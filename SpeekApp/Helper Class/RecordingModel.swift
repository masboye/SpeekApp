//
//  RecordingModel.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 16/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation


class RecordingModel{
    var date: Date
    var title: String
    var video: VideoModel
    
    init(title: String, date: Date, video: VideoModel) {
        self.title = title
        self.date = date
        self.video = video
    }
}
