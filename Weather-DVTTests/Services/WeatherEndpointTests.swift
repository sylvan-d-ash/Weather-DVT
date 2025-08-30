//
//  WeatherEndpointTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct WeatherEndpointTests {
    @Test("path")
    func testPath() {
        #expect(WeatherEndpoint.current(lat: 0, lon: 0).path == "/data/2.5/weather")
        #expect(WeatherEndpoint.forecast5Days(lat: 0, lon: 0).path == "/data/2.5/forecast")
    }

    @Test("parameters")
    func testParameters() {
        let currentParameters = WeatherEndpoint.current(lat: 0, lon: 0).parameters
        let forecastParameters = WeatherEndpoint.forecast5Days(lat: 0, lon: 0).parameters
        #expect(currentParameters?.keys.contains("lat") == true)
        #expect(currentParameters?.keys.contains("lon") == true)
        #expect(currentParameters?.keys.contains("units") == true)
        #expect(currentParameters?["lat"] as? Double == 0)
        #expect(forecastParameters?.keys.contains("lat") == true)
        #expect(forecastParameters?["lat"] as? Double == 0)
        #expect(forecastParameters?.keys.contains("lon") == true)
        #expect(forecastParameters?.keys.contains("units") == true)
    }
}
