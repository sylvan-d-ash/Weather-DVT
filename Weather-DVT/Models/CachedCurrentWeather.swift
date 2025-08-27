//
//  CachedCurrentWeather.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

@Model
final class CachedCurrentWeather {
    var currentTempCelcius: Double
    var minTempCelcius: Double?
    var maxTempCelcius: Double?
    var main: String?
    var lastUpdated: Date

    var location: CachedLocation?

    init(currentTempCelcius: Double, minTempCelcius: Double?, maxTempCelcius: Double?, main: String?) {
        self.currentTempCelcius = currentTempCelcius
        self.minTempCelcius = minTempCelcius
        self.maxTempCelcius = maxTempCelcius
        self.main = main
        self.lastUpdated = .now
    }
}
