//
//  PracticeResult.swift
//  SpeekApp
//
//  Created by boy setiawan on 19/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation


struct PracticeResult{
    
    let duration: Float
    let smile: Int
    let notSmileAccumulation : Int
    let eyeClosedAccumulation: Int
    let focusOnLeftSide: Int
    let focusOnRightSide: Int
    let focusOnCenterSide: Int
    let videoURL: URL
    
    init(duration:Float, smile:Int,notSmileAccumulation: Int,eyeClosedAccumulation:Int, focusOnLeftSide: Int, focusOnRightSide: Int, focusOnCenterSide: Int, url:URL) {
        self.duration = duration
        self.smile = smile
        self.notSmileAccumulation = notSmileAccumulation
        self.eyeClosedAccumulation = eyeClosedAccumulation
        self.focusOnLeftSide = focusOnLeftSide
        self.focusOnRightSide = focusOnRightSide
        self.focusOnCenterSide = focusOnCenterSide
        self.videoURL = url
    }
}
