//
//  TemperatureUnit.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Foundation

enum TemperatureUnit: String, Identifiable, CaseIterable, Codable {
    case celcius
    case fahrenheit

    var id: String { self.rawValue }

    var name: String {
        switch self {
        case .celcius: return "Celcius"
        case .fahrenheit: return "Fahrenheit"
        }
    }

    var symbol: String {
        switch self {
        case .celcius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}
