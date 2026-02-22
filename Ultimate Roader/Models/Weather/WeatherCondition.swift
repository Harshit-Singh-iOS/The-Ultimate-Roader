//
// WeatherCondition.swift
// Ultimate Roader
//
// Created by Harshit on 2/21/26.
// Copyright © 2026 RJT. All rights reserved.
//

import Foundation

enum WeatherCondition: String {
    case Thunderstorm_with_light_rain = "thunderstorm with light rain"
    case Thunderstorm_with_rain = "thunderstorm with rain"
    case Thunderstorm_with_heavy_rain = "thunderstorm with heavy rain"
    case Light_thunderstorm = "light thunderstorm"
    case Thunderstorm = "thunderstorm"
    case Heavy_thunderstorm = "heavy thunderstorm"
    case Ragged_thunderstorm = "Ragged thunderstorm"
    case Thunderstorm_with_light_drizzle = "thunderstorm with light drizzle"
    case Thunderstorm_with_drizzle = "thunderstorm with drizzle"
    case Thunderstorm_with_heavy_drizzle = "thunderstorm with heavy drizzle"
    case Light_intensity_drizzle = "light intensity drizzle"
    case Drizzle = "rainy"
    case Heavy_intensity_drizzle = "heavy intensity drizzle"
    case Light_intensity_drizzle_rain = "light intensity drizzle rain"
    case Drizzle_rain = "drizzle rain"
    case Heavy_intensity_drizzle_rain = "heavy intensity drizzle rain"
    case Shower_rain_and_drizzle = "shower rain and drizzle"
    case Heavy_shower_rain_and_drizzle = "heavy shower rain and drizzle"
    case Shower_drizzle = "shower drizzle"
    case Light_rain = "light rain"
    case Moderate_rain = "moderate rain"
    case Heavy_intensity_rain = "heavy intensity rain"
    case Very_heavy_rain = "very heavy rain"
    case Extreme_rain = "extreme rain"
    case Freezing_rain = "freezing rain"
    case Light_intensity_shower_rain = "light intensity shower rain"
    case Shower_rain = "shower rain"
    case Heavy_intensity_shower_rain = "heavy intensity shower rain"
    case Ragged_shower_rain = "ragged shower rain"
    case Light_snow = "light snow"
    case Snow = "snow"
    case Heavy_snow = "heavy snow"
    case Sleet = "sleet"
    case Shower_sleet = "shower sleet"
    case Light_rain_and_snow = "light rain and snow"
    case Rain_and_snow = "rain and snow"
    case Light_shower_snow = "light shower snow"
    case Shower_snow = "shower snow"
    case Heavy_shower_snow = "heavy shower snow"
    case Mist = "mist"
    case Smoke = "smoke"
    case Haze = "haze"
    case Sand_dust_whirls = "sand, dust whirls"
    case Fog = "fog"
    case Sand = "sand"
    case Dust = "dust"
    case Volcanic_ash = "volcanic ash"
    case Squalls = "squalls"
    case Tornado = "tornado"
    case Clear_sky = "clear sky"
    case Few_clouds = "few clouds"
    case Scattered_clouds = "scattered clouds"
    case Broken_clouds = "broken clouds"
    case Overcast_clouds = "overcast clouds"
    case Cloud = "clouds"
    case Rain = "rain"
    
    var title : String {
        switch self {
        case .Thunderstorm_with_light_rain:
            return "thunder_storm"
        case .Thunderstorm_with_rain :
            return "thunder_storm"
        case .Thunderstorm_with_heavy_rain:
            return "thunder_storm"
        case .Light_thunderstorm:
            return "thunder_storm"
        case .Thunderstorm:
            return "thunder_storm"
        case .Heavy_thunderstorm:
            return "thunder_storm"
        case .Ragged_thunderstorm:
            return "thunder_storm"
        case .Thunderstorm_with_light_drizzle:
            return "thunder_storm"
        case .Thunderstorm_with_drizzle:
            return "thunder_storm"
        case .Thunderstorm_with_heavy_drizzle:
            return "thunder_storm"
        case .Light_intensity_drizzle:
            return "rainy"
        case .Drizzle:
            return "rainy"
        case .Heavy_intensity_drizzle:
            return "rainy"
        case .Light_intensity_drizzle_rain:
            return "rainy"
        case .Drizzle_rain:
            return "rainy"
        case .Heavy_intensity_drizzle_rain:
            return "rainy"
        case .Shower_rain_and_drizzle:
            return "rainy"
        case .Heavy_shower_rain_and_drizzle:
            return "rainy"
        case .Shower_drizzle:
            return "rainy"
        case .Light_rain:
            return "scattered_showers"
        case .Moderate_rain:
            return "scattered_showers"
        case .Heavy_intensity_rain:
            return "scattered_showers"
        case .Very_heavy_rain:
            return "scattered_showers"
        case .Extreme_rain:
            return "scattered_showers"
        case .Freezing_rain:
            return "snow"
        case .Light_intensity_shower_rain:
            return "rainy_wind"
        case .Shower_rain:
            return "rainy_wind"
        case .Heavy_intensity_shower_rain:
            return "rainy_wind"
        case .Ragged_shower_rain:
            return "rainy_wind"
        case .Light_snow:
            return "snow"
        case .Snow:
            return "snow"
        case .Heavy_snow:
            return "snow"
        case .Sleet:
            return "snow"
        case .Shower_sleet:
            return "snow"
        case .Light_rain_and_snow:
            return "snow"
        case .Rain_and_snow:
            return "snow"
        case .Light_shower_snow:
            return "snow"
        case .Shower_snow:
            return "snow"
        case .Heavy_shower_snow:
            return "snow"
        case .Mist:
            return "cold_breeze"
        case .Smoke:
            return "cold_breeze"
        case .Haze:
            return "cold_breeze"
        case .Sand_dust_whirls:
            return "cold_breeze"
        case .Fog:
            return "cold_breeze"
        case .Sand:
            return "cold_breeze"
        case .Dust:
            return "cold_breeze"
        case .Volcanic_ash:
            return "cold_breeze"
        case .Squalls:
            return "cold_breeze"
        case .Clear_sky:
            return "sun"
        case .Few_clouds:
            return "cloudy"
        case .Scattered_clouds:
            return "cloudy"
        case .Broken_clouds:
            return "cloudy"
        case .Overcast_clouds:
            return "cloudy"
        case .Cloud:
            return "cloudy"
        case .Tornado:
            return "tornado"
        case .Rain:
            return "rain"
        }
    }
}
