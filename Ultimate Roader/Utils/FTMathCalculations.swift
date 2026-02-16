//
//  FTMathCalculations.swift
//  Ardhi
//
//  Created by Fatima Hussain on 10/8/15.
//  Copyright © 2015 Solutions 4 Mobility. All rights reserved.
//

import UIKit
import CoreLocation

extension Double {
    func degreesToRadians() -> Double { return self * Double.pi / 180.0 }
    func radiansToDegrees() -> Double { return self * 180.0 / Double.pi }
}

class FTMathCalculations: NSObject {
    
    class func directionForCoordinate(_ coordinates:CLLocationCoordinate2D) -> String {
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        var latitudeSeconds = Int(round(abs(latitude * 3600)))
        let latitudeDegrees = latitudeSeconds / 3600
        latitudeSeconds = latitudeSeconds % 3600
        let latitudeMinutes = latitudeSeconds / 60
        latitudeSeconds %= 60
        
        var longitudeSeconds = Int(round(abs(longitude * 3600)))
        let longitudeDegrees = longitudeSeconds / 3600
        longitudeSeconds = longitudeSeconds % 3600
        let longitudeMinutes = Int(longitudeSeconds / 60)
        longitudeSeconds %= 60
        
        let latitudeDirection = (latitude >= 0) ? "N" : "S"
        let longitudeDirection = (longitude >= 0) ? "E" : "W"
        
        return "\(latitudeDirection) \(latitudeDegrees)° \(latitudeMinutes)' \(latitudeSeconds)\"\n\(longitudeDirection) \(longitudeDegrees)° \(longitudeMinutes)' \(longitudeSeconds)\""
    }
    
    class func timeInHoursAndMins(_ timeWaiting: TimeInterval) -> (hours: Int, mins: Int, seconds: Int) {
        let totalTime = round(timeWaiting)
        let hours = Int(totalTime / 3600)
        let mins = Int((totalTime.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeWaiting) % 60
        return (hours, mins, seconds)
    }
}
