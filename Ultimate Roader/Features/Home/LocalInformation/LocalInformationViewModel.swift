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
    var headingRadians: CGFloat = 0
    var directionText: String = ""
    var isLoading: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        weatherImage = defaultWeatherImage
        super.init()
        setupLocationServices()
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
        headingRadians = -radians
    }
    
    private func getWeather(lat: String, long: String) {
        Weather.sharedInstance.get_weather(latitude: lat, longitude: long) { [weak self] temp_desc in
            guard let self else { return }
            Task {
                if let t_d = temp_desc as? (String, String, String) {
                    let name = Weather.Condition(rawValue: t_d.1)?.title
                    self.weatherImage = UIImage(named: name ?? "clouds") ?? self.defaultWeatherImage
                    self.temperatureText = "\(t_d.0)\u{2103}"
                    self.placeText = t_d.2
                }
                self.isLoading = false
            }
        }
    }
}
