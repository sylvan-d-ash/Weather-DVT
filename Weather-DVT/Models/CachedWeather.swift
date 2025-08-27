//
//  CachedWeather.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

@Model
final class CachedWeather {
    var currentTempCelcius: Double
    var minTempCelcius: Double?
    var maxTempCelcius: Double?
    var main: String
    var lastUpdated: Date

    var location: CachedLocation?

    init(currentTempCelcius: Double, minTempCelcius: Double? = nil, maxTempCelcius: Double? = nil, main: String, lastUpdated: Date) {
        self.currentTempCelcius = currentTempCelcius
        self.minTempCelcius = minTempCelcius
        self.maxTempCelcius = maxTempCelcius
        self.main = main
        self.lastUpdated = lastUpdated
    }
}
