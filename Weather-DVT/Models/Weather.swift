//
//  Weather.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation
import SwiftUI

struct Weather: Identifiable {
    enum Condition {
        case sunny
        case rainy
        case cloudy

        var text: String {
            switch self {
            case .sunny: return "SUNNY"
            case .rainy: return "RAINY"
            case .cloudy: return "CLOUDY"
            }
        }

        var icon: String {
            switch self {
            case .sunny: return "clear"
            case .rainy: return "rain"
            case .cloudy: return "partlysunny"
            }
        }

        func backgroundColor(base: String = "forest_") -> Color {
            switch self {
            case .rainy: return .rainy
            case .cloudy: return Color(base + "cloudy")
            case .sunny: return Color(base + "sunny")
            }
        }

        func backgroundImage(base: String = "forest_") -> String {
            switch self {
            case .sunny: return base + "sunny"
            case .rainy: return base + "rainy"
            case .cloudy: return base + "cloudy"
            }
        }
    }

    let id = UUID()
    let date: Date
    let main: String?
    let currentTempInCelcius: Double
    let minTempInCelcius: Double?
    let maxTempInCelcius: Double?

    var condition: Condition {
        switch main?.lowercased() {
        case "thunderstorm", "drizzle", "rain": return .rainy
        case "snow", "atmosphere", "clouds": return .cloudy
        case "clear": return .sunny
        default: return .sunny
        }
    }
}

extension Weather {
    init(from cache: CachedWeather) {
        date = cache.lastUpdated
        main = cache.main
        currentTempInCelcius = cache.currentTempCelcius
        minTempInCelcius = cache.minTempCelcius
        maxTempInCelcius = cache.maxTempCelcius
    }
}
