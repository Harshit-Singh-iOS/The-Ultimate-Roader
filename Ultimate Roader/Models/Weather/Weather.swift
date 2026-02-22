//
//  Weather.swift
//  Ardhi
//
//  Created by Fatima Hussain on 10/13/15.
//  Updated to Codable by Assistant on 2/15/26.
//

import UIKit

struct WeatherSummary {
    let temperatureC: Int
    let description: String
    let city: String
}

struct WeatherResponse: Codable {
    let city: City
    let list: [Forecast]
    
    struct City: Codable { let name: String }
    
    struct Forecast: Codable {
        let main: Main
        let weather: [Weather]
        
        struct Main: Codable { let temp: Double }
        struct Weather: Codable { let description: String }
    }
}

