//
//  Weather.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

struct Weather: Identifiable {
    enum Condition {
        case sunny
        case rainy
        case cloudy
    }

    let id = UUID()
    let date: Date
    let main: String
    let currentTemperature: Double
    let minTemperature: Double?
    let maxTemperature: Double?

    var condition: Condition {
        switch main {
        case "thunderstorm", "drizzle", "rain": return .rainy
        case "snow", "atmosphere", "clouds": return .cloudy
        case "clear": return .sunny
        default: return .sunny
        }
    }
}
