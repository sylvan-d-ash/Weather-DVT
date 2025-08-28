//
//  WeatherModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct WeatherModelTests {
    @Test("condition from API maps correctly")
    func testConditionFromAPI() {
        #expect(Weather.mock(main: nil).condition == .sunny)
        #expect(Weather.mock(main: "unknown").condition == .sunny)
        #expect(Weather.mock(main: "clear").condition == .sunny)
        #expect(Weather.mock(main: "snow").condition == .cloudy)
        #expect(Weather.mock(main: "atmosphere").condition == .cloudy)
        #expect(Weather.mock(main: "clouds").condition == .cloudy)
        #expect(Weather.mock(main: "thunderstorm").condition == .rainy)
        #expect(Weather.mock(main: "drizzle").condition == .rainy)
        #expect(Weather.mock(main: "rain").condition == .rainy)
    }

    @Test("initialize from CachedCurrentWeather")
    func testInitializeFromCachedCurrentWeather() {
        let weather = CachedCurrentWeather(
            currentTempCelcius: 22.5,
            minTempCelcius: 18.0,
            maxTempCelcius: 25.4,
            main: nil
        )
        let sut = Weather(from: weather)
        #expect(sut.currentTempInCelcius == weather.currentTempCelcius)
        #expect(sut.minTempInCelcius == weather.minTempCelcius)
        #expect(sut.maxTempInCelcius == weather.maxTempCelcius)
        #expect(sut.main == weather.main)
        #expect(sut.condition == .sunny)
    }

    @Test("initialize from CachedForecastWeather")
    func testInitializeFromCachedForecastWeather() {
        let weather = CachedCurrentWeather(
            currentTempCelcius: 22.5,
            minTempCelcius: 18.0,
            maxTempCelcius: 25.4,
            main: "clouds"
        )
        let sut = Weather(from: weather)
        #expect(sut.currentTempInCelcius == weather.currentTempCelcius)
        #expect(sut.minTempInCelcius == weather.minTempCelcius)
        #expect(sut.maxTempInCelcius == weather.maxTempCelcius)
        #expect(sut.main == weather.main)
        #expect(sut.condition == .cloudy)
    }
}
