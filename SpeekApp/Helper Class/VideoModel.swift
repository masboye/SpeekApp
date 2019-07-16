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
    var attention: Int64
    var smileDuration: Int64
    
    init(title: String, filePath: String, eyeContactLost: Int64, attention: Int64, smileDuration: Int64) {
        self.title = title
        self.filePath = filePath
        self.eyeContactLost = eyeContactLost
        self.attention = attention
        self.smileDuration = smileDuration
    }
}
