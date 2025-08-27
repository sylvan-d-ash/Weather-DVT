//
//  CachedForecastWeather.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

@Model
final class CachedForecastWeather {
    var currentTempCelcius: Double
    var minTempCelcius: Double?
    var maxTempCelcius: Double?
    var main: String?
    var date: Date

    var location: CachedLocation?

    init(
        currentTempCelcius: Double,
        minTempCelcius: Double?,
        maxTempCelcius: Double?,
        main: String?,
        date: Date
    ) {
        self.currentTempCelcius = currentTempCelcius
        self.minTempCelcius = minTempCelcius
        self.maxTempCelcius = maxTempCelcius
        self.main = main
        self.date = date
    }
}
