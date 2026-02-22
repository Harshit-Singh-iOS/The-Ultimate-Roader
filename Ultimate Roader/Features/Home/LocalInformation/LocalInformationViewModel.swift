//
//  LocalInformationViewModel.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import Foundation
import CoreLocation
import UIKit

@Observable
class LocalInformationViewModel: NSObject, CLLocationManagerDelegate {
    private let defaultWeatherImage = UIImage(systemName: "cloud.sun")!
    var temperatureText: String = "\u{2103}"
    var placeText: String = ""
    var weatherImage: UIImage
    var directionText: String = ""
    var isLoading: Bool = false
    var updateHeading: ((CGFloat) -> Void)?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        weatherImage = defaultWeatherImage
        super.init()
        setupLocationServices()
    }
    
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    private func setupLocationServices() {
        isLoading = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            locationManager.stopUpdatingLocation()
            getWeather(lat: String(describing: loc.coordinate.latitude), long: String(describing: loc.coordinate.longitude))
            directionText = FTMathCalculations.directionForCoordinate(loc.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let radians = CGFloat(newHeading.magneticHeading.degreesToRadians())
        updateHeading?(-radians)
    }
    
    private func getWeather(lat: String, long: String) {
        Task { @MainActor in
            self.isLoading = true
            let summary = await WeatherDataManager.shared.getWeather(latitude: lat, longitude: long)
            let name = WeatherCondition(rawValue: summary.description)?.title
            self.weatherImage = UIImage(named: name ?? "clouds") ?? self.defaultWeatherImage
            self.temperatureText = "\(summary.temperatureC)\u{2103}"
            self.placeText = summary.city
            self.isLoading = false
        }
    }
}
