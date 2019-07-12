//
//  RecordTimer.swift
//  MC2
//
//  Created by boy setiawan on 02/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation


class CountDownTimer{
    
    private var seconds = 0
    
    
    init(initValue:Int = 5) {
        
        self.seconds = initValue + 1
        
    }
    
    func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        
    }
    
    func resetTimer() {
        seconds = 5     //This will decrement(count down)the seconds.
        
    }
    
    
    func getCounter() -> Int{
        return seconds
    }
    
}
