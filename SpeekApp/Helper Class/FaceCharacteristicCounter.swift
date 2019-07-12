//
//  FaceCharacteristicCounter.swift
//  SpeekApp
//
//  Created by boy setiawan on 11/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

struct FaceCharacteristicCounter {
    private var lastSmileTime = Date()
    private var smileAccumulation = 0
    private var smileStatus = FaceCharacteristic.notSmilling
    var isFirstTimeSmile = true
    
    //calendar for time operation
    var calendar = Calendar.current
    
    var smilePerimeter: FaceCharacteristic {
        get {
            return smileStatus
        }
        set {
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
                    }
                    
                case .notSmilling:
                    lastSmileTime = Date()
                default: break
                
                }
                
            }
        }
    }
    
    private var lastEyeClosedTime = Date()
    private var eyeClosedAccumulation = 0
    private var eyeClosedStatus = FaceCharacteristic.eyesOpen
    var isFirstTimeEyesClosed = true
    
    var eyesPerimeter: FaceCharacteristic {
        get {
            return eyeClosedStatus
        }
        set {
            if newValue != eyeClosedStatus {
                
                switch newValue{
                case .eyesClosed:
                    if isFirstTimeEyesClosed{
                        //print("First time eyes closed")
                        lastEyeClosedTime = Date()
                        isFirstTimeEyesClosed = false
                    }else{
                        let currentTime = Date()
                        
                        eyeClosedAccumulation += calendar.compare(currentTime, to: lastEyeClosedTime, toGranularity: .second).rawValue
                        lastEyeClosedTime = currentTime
                        //print("eyeClosedAccumulation \(eyeClosedAccumulation)")
                    }
                case .eyesOpen:
                    lastEyeClosedTime = Date()
                default: break
                    
                }
                
            }
        }
    }
    
    private var lastTurnLeftTime = Date()
    private var turnLeftAccumulation = 0
    private var turnLeftStatus = FaceCharacteristic.straight
    var isFirstTurnLeft = true
    
    var turnLeftPerimeter: FaceCharacteristic {
        get {
            return turnLeftStatus
        }
        set {
            if newValue != turnLeftStatus {
                
                switch newValue{
                case .turnLeft:
                    if isFirstTurnLeft{
                        //print("First time turn left")
                        lastTurnLeftTime = Date()
                        isFirstTurnLeft = false
                    }else{
                        let currentTime = Date()
                        
                        turnLeftAccumulation += calendar.compare(currentTime, to: lastTurnLeftTime, toGranularity: .second).rawValue
                        lastTurnLeftTime = currentTime
                        //print("turnLeftAccumulation \(turnLeftAccumulation)")
                    }
                
                default:
                    lastTurnLeftTime = Date()
                    lastStraightTime = Date()
                    
                }
                
            }
        }
    }
    
    private var lastTurnRightTime = Date()
    private var turnRightAccumulation = 0
    private var turnRightStatus = FaceCharacteristic.straight
    var isFirstTurnRight = true
    
    var turnRightPerimeter: FaceCharacteristic {
        get {
            return turnRightStatus
        }
        set {
            if newValue != turnRightStatus {
                
                switch newValue{
                case .turnRight:
                    if isFirstTurnRight{
                        print("First time turn right")
                        lastTurnRightTime = Date()
                        isFirstTurnRight = false
                    }else{
                        let currentTime = Date()
                        
                        turnRightAccumulation += calendar.compare(currentTime, to: lastTurnRightTime, toGranularity: .second).rawValue
                        lastTurnRightTime = currentTime
                        print("turnRightAccumulation \(turnRightAccumulation)")
                    }
                    
                default:
                    lastTurnRightTime = Date()
                    lastStraightTime = Date()
                    
                }
                
            }
        }
    }
    
    private var lastStraightTime = Date()
    private var straightAccumulation = 0
    private var straightStatus = FaceCharacteristic.turnLeft
    var isFirstStraight = true
    
    var straightPerimeter: FaceCharacteristic {
        get {
            return straightStatus
        }
        set {
            if newValue != straightStatus {
                
                switch newValue{
                case .straight:
                    if isFirstStraight{
                        print("First time Straight")
                        lastStraightTime = Date()
                        isFirstStraight = false
                    }else{
                        let currentTime = Date()
                        
                        straightAccumulation += calendar.compare(currentTime, to: lastStraightTime, toGranularity: .second).rawValue
                        lastStraightTime = currentTime
                        print("straightAccumulation \(straightAccumulation)")
                    }
                    
                default:
                    lastStraightTime = Date()
                    lastTurnLeftTime = Date()
                    lastTurnRightTime = Date()
                    
                }
                
            }
        }
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
