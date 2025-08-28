//
//  MockWeatherService.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
@testable import Weather_DVT

enum MockTestError: Error {
    case notImplemented
    case dummyError
}

final class MockWeatherService: WeatherService {
    private(set) var fetchCurrentWeatherLat: Double?
    private(set) var fetchCurrentWeatherLon: Double?
    private(set) var fetch5DaysForecastLat: Double?
    private(set) var fetch5DaysForecastLon: Double?

    var currentWeatherResult: Result<Weather, Error> = .failure(MockTestError.notImplemented)
    var forecastWeatherResult: Result<Forecast, Error> = .failure(MockTestError.notImplemented)

    func fetchCurrentWeather(lat: Double, lon: Double) async -> Result<Weather, Error> {
        fetchCurrentWeatherLat = lat
        fetchCurrentWeatherLon = lon
        return currentWeatherResult
    }

    func fetch5DaysForecast(lat: Double, lon: Double) async -> Result<Forecast, Error> {
        fetch5DaysForecastLat = lat
        fetch5DaysForecastLon = lon
        return forecastWeatherResult
    }
}
