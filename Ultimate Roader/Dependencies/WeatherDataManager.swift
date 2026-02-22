//
//  WeatherDataManager.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/21/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation

typealias completionHandler = (Any) -> ()

class WeatherDataManager: NSObject {
    static let shared = WeatherDataManager()
    private override init() { }
    
    // MARK: - Async Codable API
    private func fetchWeather(latitude: String, longitude: String) async throws -> WeatherSummary {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(Constants.kWEATHERAPIKEY)"
        guard let url = URL(string: urlString) else { throw NSError(domain: "Bad URL", code: -1) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: data)
        guard let first = response.list.first else { throw NSError(domain: "No forecast", code: -2) }
        let tempC = Int(first.main.temp - 273.15)
        let desc = first.weather.first?.description ?? ""
        return WeatherSummary(temperatureC: tempC, description: desc, city: response.city.name)
    }
    
    func getWeather(latitude: String, longitude: String) async -> WeatherSummary {
        do {
            let summary = try await fetchWeather(latitude: latitude, longitude: longitude)
            return summary
        } catch {
            return .init(temperatureC: 0, description: "", city: "")
        }
    }
}
