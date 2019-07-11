//
//  RecordTimer.swift
//  MC2
//
//  Created by boy setiawan on 02/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import UIKit

class RecordTimer{
    
    private var seconds = 0
    
    
    init(initValue:Int = 0) {
        
        self.seconds = initValue
        
    }
    
    func updateTimer() {
        seconds += 1     //This will decrement(count down)the seconds.
        
    }
    
    func resetTimer() {
        seconds = 0     //This will decrement(count down)the seconds.
        
    }
    
    func getTime() -> String {
        
        let time = TimeInterval(seconds)
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}
