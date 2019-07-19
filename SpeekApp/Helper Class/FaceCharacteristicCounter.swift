//
//  FaceCharacteristicCounter.swift
//  SpeekApp
//
//  Created by boy setiawan on 11/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

struct FaceCharacteristicCounter {
    
    //calendar for time operation
    var calendar = Calendar.current
    
    var isCalculating = true
    
    //vars for smile
    private var lastSmileTime = Date()
    private var smileAccumulation = 0
    private var smileStatus = FaceCharacteristic.notSmilling
    var isFirstTimeSmile = true
    
    var smileTime: Int{
        get{
            return smileAccumulation
        }
    }
    var smilePerimeter: FaceCharacteristic {
        get {
            return smileStatus
        }
        set {
            
            if isCalculating{
                if newValue != smileStatus {
                    
                    switch newValue{
                    case .smilling:
                        if isFirstTimeSmile{
                            //print("First time smile")
                            lastSmileTime = Date()
                            isFirstTimeSmile = false
                        }else{
                            let currentTime = Date()
                            
                            smileAccumulation += calendar.compare(currentTime, to: lastSmileTime, toGranularity: .second).rawValue
                            lastSmileTime = currentTime
                            //print("smileAccumulation \(smileAccumulation)")
                            lastNotSmileAccumulation = 0
                        }
                        
                    case .notSmilling:
                        lastSmileTime = Date()
                        
                    default: break
                        
                    }
                    
                }
            }
        }
    }
    
    //vars for not smiling
    private var lastNotSmileTime = Date()
    private var notSmileAccumulation = 0
    private var notSmileStatus = FaceCharacteristic.smilling
    var isFirstTimeNotSmile = true
    private var lastNotSmileAccumulation = 0
    
    var noSmileTime: Int{
        get{
            return notSmileAccumulation
        }
    }
    
    var notSmilePerimeter: FaceCharacteristic {
        get {
            return notSmileStatus
        }
        set {
            if isCalculating{
                if newValue != notSmileStatus {
                    
                    switch newValue{
                    case .notSmilling:
                        if isFirstTimeNotSmile{
                            //print("First time not smiling")
                            lastNotSmileTime = Date()
                            isFirstTimeNotSmile = false
                        }else{
                            let currentTime = Date()
                            let difference = calendar.compare(currentTime, to: lastNotSmileTime, toGranularity: .second).rawValue
                            notSmileAccumulation += difference
                            lastNotSmileAccumulation += difference
                            lastNotSmileTime = currentTime
                            
                            //print("notsmileAccumulation \(notSmileAccumulation)")
                            //print("lastNotSmileAccumulation \(lastNotSmileAccumulation)")
                        }
                        
                    case .smilling:
                        lastNotSmileTime = Date()
                        lastNotSmileAccumulation = 0
                    default: break
                        
                    }
                    
                }
            }
        }
    }
    
    var lastNotSmilling: Int {
        get {
            return lastNotSmileAccumulation
        }
    }
    
    private var lastEyeClosedTime = Date()
    private var eyeClosedAccumulation = 0
    private var eyeClosedStatus = FaceCharacteristic.eyesOpen
    var isFirstTimeEyesClosed = true
    private var lastEyesClosedAccumulation = 0
    private var eyesClosedTimeArray = [Date]()
    
    var eyesPerimeter: FaceCharacteristic {
        get {
            return eyeClosedStatus
        }
        set {
            if isCalculating{
                if newValue != eyeClosedStatus {
                    
                    switch newValue{
                    case .eyesClosed:
                        if isFirstTimeEyesClosed{
                            //print("First time eyes closed")
                            lastEyeClosedTime = Date()
                            isFirstTimeEyesClosed = false
                            
                        }else{
                            let currentTime = Date()
                            let difference = calendar.compare(currentTime, to: lastEyeClosedTime, toGranularity: .second).rawValue
                            eyeClosedAccumulation += difference
                            lastEyeClosedTime = currentTime
                            //print("eyeClosedAccumulation \(eyeClosedAccumulation)")
                            
                            if difference > 0 {
                                eyesClosedTimeArray.append(currentTime)
                            }
                            
                            if eyesClosedTimeArray.count >= 4{
                                eyesClosedTimeArray.removeFirst()
                                //let dateSorted = eyesClosedTimeArray.sorted()
                                //print("\(dateSorted)")
                                guard let maxDate = eyesClosedTimeArray.max() else { return  }
                                guard let minDate = eyesClosedTimeArray.min() else { return  }
                                let second = Calendar.current.dateComponents([.second], from: minDate, to: maxDate).second
                                //print("the seconds = \(second)")
                                lastEyesClosedAccumulation = second ?? 0
                                eyesClosedTimeArray.removeAll()
                            }
                            
                            
                        }
                    case .eyesOpen:
                        //print("Eyes Open")
                        lastEyeClosedTime = Date()
                        lastEyesClosedAccumulation = 0
                    default: break
                        
                    }
                    
                }
            }
        }
        
    }
    var lastEyesClosed: Int {
        get {
            return lastEyesClosedAccumulation
        }
        set{
            lastEyesClosedAccumulation = newValue
        }
    }
    
    var lostEyeContactTime: Int{
        get{
            return eyeClosedAccumulation
        }
    }
    
    private var lastTurnLeftTime = Date()
    private var turnLeftAccumulation = 0
    private var turnLeftStatus = FaceCharacteristic.straight
    var isFirstTurnLeft = true
    private var lastTurnLeftAccumulation = 0
    
    var focusOnLeftTime: Int{
        get{
            return turnLeftAccumulation
        }
    }
    
    var lastTurnLeft: Int {
        get {
            return lastTurnLeftAccumulation
        }
    }
    var turnLeftPerimeter: FaceCharacteristic {
        get {
            return turnLeftStatus
        }
        set {
            if isCalculating{
                if newValue != turnLeftStatus {
                    
                    switch newValue{
                    case .turnLeft:
                        if isFirstTurnLeft{
                            //print("First time turn left")
                            lastTurnLeftTime = Date()
                            isFirstTurnLeft = false
                        }else{
                            let currentTime = Date()
                            let difference = calendar.compare(currentTime, to: lastTurnLeftTime, toGranularity: .second).rawValue
                            turnLeftAccumulation += difference
                            lastTurnLeftAccumulation += difference
                            lastTurnLeftTime = currentTime
                            //print("turnLeftAccumulation \(turnLeftAccumulation)")
                            lastTurnRightAccumulation = 0
                            lastStraightAccumulation = 0
                        }
                        
                    default:
                        lastTurnLeftTime = Date()
                        lastStraightTime = Date()
                        lastTurnLeftAccumulation = 0
                        
                    }
                    
                }
            }
        }
    }
    
    private var lastTurnRightTime = Date()
    private var turnRightAccumulation = 0
    private var turnRightStatus = FaceCharacteristic.straight
    var isFirstTurnRight = true
    private var lastTurnRightAccumulation = 0
    
    var focusOnRightTime: Int{
        get{
            return turnRightAccumulation
        }
    }
    var lastTurnRight: Int {
        get {
            return lastTurnRightAccumulation
        }
    }
    var turnRightPerimeter: FaceCharacteristic {
        get {
            return turnRightStatus
        }
        set {
            if isCalculating{
                if newValue != turnRightStatus {
                    
                    switch newValue{
                    case .turnRight:
                        if isFirstTurnRight{
                            //print("First time turn right")
                            lastTurnRightTime = Date()
                            isFirstTurnRight = false
                        }else{
                            let currentTime = Date()
                            let difference = calendar.compare(currentTime, to: lastTurnRightTime, toGranularity: .second).rawValue
                            turnRightAccumulation += difference
                            lastTurnRightAccumulation += difference
                            
                            lastTurnRightTime = currentTime
                            //print("turnRightAccumulation \(turnRightAccumulation)")
                            lastStraightAccumulation = 0
                            lastTurnLeftAccumulation = 0
                        }
                        
                    default:
                        lastTurnRightTime = Date()
                        lastStraightTime = Date()
                        lastTurnRightAccumulation = 0
                        
                    }
                    
                }
            }
        }
    }
    
    private var lastStraightTime = Date()
    private var straightAccumulation = 0
    private var straightStatus = FaceCharacteristic.turnLeft
    var isFirstStraight = true
    private var lastStraightAccumulation = 0
    
    var lastStraight: Int {
        get {
            return lastStraightAccumulation
        }
    }
    
    var straightPerimeter: FaceCharacteristic {
        get {
            return straightStatus
        }
        set {
            
            if isCalculating{
                if newValue != straightStatus {
                    
                    switch newValue{
                    case .straight:
                        if isFirstStraight{
                            //print("First time Straight")
                            lastStraightTime = Date()
                            isFirstStraight = false
                        }else{
                            let currentTime = Date()
                            let difference = calendar.compare(currentTime, to: lastStraightTime, toGranularity: .second).rawValue
                            straightAccumulation += difference
                            lastStraightAccumulation += difference
                            
                            lastStraightTime = currentTime
                            //print("straightAccumulation \(straightAccumulation) - lastStraight \(lastStraightAccumulation)")
                            
                            lastTurnRightAccumulation = 0
                            lastTurnLeftAccumulation = 0
                        }
                        
                    default:
                        lastStraightTime = Date()
                        lastTurnLeftTime = Date()
                        lastTurnRightTime = Date()
                        lastStraightAccumulation = 0
                    }
                    
                }
            }
        }
    }
    
    var focusOnCenterTime: Int{
        get{
            return straightAccumulation
        }
    }
    
    mutating func resetCalculation(){
        eyeClosedAccumulation = 0
        smileAccumulation = 0
        notSmileAccumulation = 0
        eyeClosedAccumulation = 0
        lastEyesClosedAccumulation = 0
        turnLeftAccumulation = 0
        lastTurnLeftAccumulation = 0
        turnRightAccumulation = 0
        lastTurnRightAccumulation = 0
        straightAccumulation = 0
        lastStraightAccumulation = 0
        
    }
}

public enum FaceCharacteristic {
    case smilling
    case notSmilling
    
    case eyesClosed
    case eyesOpen
    
    case turnLeft
    case turnRight
    case straight
}
