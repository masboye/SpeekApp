//
//  VideoModel.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 16/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

class VideoModel {
    var title: String
    var filePath: String
    var eyeContactLost: Int64
    var attentionLeft: Int64
    var attentionRight: Int64
    var attentionCenter: Int64
    var smileDuration: Int64
    
    init() {
        self.title = ""
        self.filePath = ""
        self.eyeContactLost = 0
        self.attentionLeft = 0
        self.attentionRight = 0
        self.attentionCenter = 0
        self.smileDuration = 0
    }
    init(title: String, filePath: String, eyeContactLost: Int64, attentionLeft: Int64, attentionRight: Int64, attentionCenter: Int64, smileDuration: Int64) {
        self.title = title
        self.filePath = filePath
        self.eyeContactLost = eyeContactLost
        self.attentionLeft = attentionLeft
        self.attentionRight = attentionRight
        self.attentionCenter = attentionCenter
        self.smileDuration = smileDuration
    }
}
