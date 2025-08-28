//
//  MockPersistenceService.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
@testable import Weather_DVT

@MainActor
final class MockPersistenceService: PersistenceService {
    var mockCachedLocation: CachedLocation?
    private(set) var didCallUpdateCacheForFreshWeather = false
    private(set) var didCallUpdateCacheForSummaries = false
    private(set) var freshWeatherLocation: WeatherLocation?
    private(set) var summariesLocation: WeatherLocation?
    private(set) var summaries: [Weather]?
    private(set) var freshWeather: Weather?

    func fetchCachedWeather(for location: WeatherLocation) -> CachedLocation? {
        return mockCachedLocation
    }

    func updateCache(for location: WeatherLocation, with freshWeather: Weather) {
        didCallUpdateCacheForFreshWeather = true
        freshWeatherLocation = location
        self.freshWeather = freshWeather
    }

    func updateCache(for location: WeatherLocation, with summaries: [Weather]) {
        didCallUpdateCacheForSummaries = true
        summariesLocation = location
        self.summaries = summaries
    }
}
