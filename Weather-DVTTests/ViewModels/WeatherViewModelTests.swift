//
//  WeatherViewModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct WeatherViewModelTests {
    var sut: WeatherView.ViewModel!
    var geocoderService: MockGeocoderService!
    var locationManager: MockUserLocationManager!
    var persistenceService: MockPersistenceService!
    var weatherService: MockWeatherService!

    init() {
        geocoderService = MockGeocoderService()
        locationManager = MockUserLocationManager()
        weatherService = MockWeatherService()
        persistenceService = MockPersistenceService()
    }

    @Test("request authorization")
    mutating func testRequestAuthorization() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        sut.requestAuthorization()

        #expect(locationManager.didCallRequestAuthorization == true)
    }

    @Test("authorization denied")
    mutating func testAuthorizationDenied() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        locationManager.simulateAuthorizationChange(status: .denied)

        #expect(sut.errorMessage == "Location access denied. Please enable it in Settings.")
        #expect(locationManager.didCallRequestLocation == false)
    }

    @Test("authorization granted")
    mutating func testAuthorizationGratend() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        locationManager.simulateAuthorizationChange(status: .authorizedWhenInUse)

        #expect(sut.errorMessage == nil)
        #expect(locationManager.didCallRequestLocation == true)
    }

    @Test("location error")
    mutating func testLocationError() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        let error = "Location update failed!"
        locationManager.simulateError(message: error)

        #expect(sut.errorMessage == error)
        #expect(geocoderService.didCallLocationDetails == false)
        #expect(persistenceService.didCallFetchCachedWeatherForLocation == false)
        #expect(persistenceService.didCallUpdateCacheForFreshWeather == false)
        #expect(persistenceService.didCallUpdateCacheForSummaries == false)
        #expect(weatherService.fetchCurrentWeatherLat == nil)
        #expect(weatherService.fetch5DaysForecastLat == nil)
    }

    @Test("location update")
    mutating func testLocationUpdate() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        locationManager.simulateLocationUpdate(coordinate: .init(latitude: 1, longitude: 1))

        #expect(sut.location?.latitude == 1)
        #expect(sut.location?.longitude == 1)
    }

    @Test("load weather without cache")
    mutating func testLoadWeatherWithoutCache() async {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )
        let mockWeather = Weather.mock()
        let mockForecast = Forecast.mock()
        weatherService.currentWeatherResult = .success(mockWeather)
        weatherService.forecastWeatherResult = .success(mockForecast)

        locationManager.simulateLocationUpdate(coordinate: .init(latitude: 1, longitude: 1))

        // wait for a brief moment to allow the async loadWeather() to complete
        try? await Task.sleep(for: .milliseconds(100))

        // assert view model state
        #expect(sut.isLoading == false)
        #expect(sut.weather?.id == mockWeather.id)
        #expect(sut.dailySummaries.isEmpty == false)
        #expect(sut.lastUpdated == "Last Update: Now")
        #expect(sut.errorMessage == nil)

        // assert cache update
        #expect(persistenceService.didCallFetchCachedWeatherForLocation == true)
        #expect(persistenceService.didCallUpdateCacheForFreshWeather == true)
        #expect(persistenceService.freshWeather == sut.weather)
        #expect(persistenceService.didCallUpdateCacheForSummaries == true)
        #expect(persistenceService.summaries == sut.dailySummaries)
    }

    @Test("load weather with cache")
    mutating func testLoadWeatherWithCache() async {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        let weather = CachedCurrentWeather(
            currentTempCelcius: 1,
            minTempCelcius: 1,
            maxTempCelcius: 1,
            main: "clear"
        )
        let location = CachedLocation(
            name: "Nairobi",
            region: "",
            latitude: 1,
            longitude: 1
        )
        location.weather = weather
        persistenceService.mockCachedLocation = location

        // act
        locationManager.simulateLocationUpdate(coordinate: .init(latitude: 1, longitude: 1))

        // wait for a brief moment to allow the async loadWeather() to complete
        try? await Task.sleep(for: .milliseconds(100))

        // assert view model state
        #expect(sut.isLoading == false)
        #expect(sut.weather?.main == weather.main)
        #expect(sut.dailySummaries.isEmpty) // none supplied
        #expect(sut.lastUpdated != nil)
        #expect(sut.lastUpdated != "Last Update: Now")
        #expect(sut.errorMessage != nil)

        // assert cache update
        #expect(persistenceService.didCallFetchCachedWeatherForLocation == true)
        // weather service failed so all these should be nil or false
        #expect(persistenceService.didCallUpdateCacheForFreshWeather == false)
        #expect(persistenceService.didCallUpdateCacheForSummaries == false)
        #expect(persistenceService.freshWeather == nil)
        #expect(persistenceService.summaries == nil)
    }

    @Test("load weather for search result")
    mutating func loadWeatherForSearchResult() async {
        let result = SearchLocation(name: "Nairobi", region: "", coordinate: .init(latitude: 1, longitude: 1))
        sut = .init(service: weatherService, searchResult: result)

        let mockWeather = Weather.mock()
        let mockForecast = Forecast.mock()
        weatherService.currentWeatherResult = .success(mockWeather)
        weatherService.forecastWeatherResult = .success(mockForecast)

        // cache load should fail even with cache location provided
        let location = CachedLocation(
            name: "Nairobi",
            region: "",
            latitude: 1,
            longitude: 1
        )
        persistenceService.mockCachedLocation = location

        // wait for a brief moment to allow the async loadWeather() to complete
        try? await Task.sleep(for: .milliseconds(100))

        // assert view model state
        #expect(sut.isLoading == false)
        #expect(sut.weather?.id == mockWeather.id)
        #expect(sut.dailySummaries.isEmpty == false)
        #expect(sut.dailySummaries.first?.main == mockForecast.list.first?.main)
        #expect(sut.lastUpdated == "Last Update: Now")
        #expect(sut.errorMessage == nil)

        // assert cache update
        #expect(persistenceService.didCallFetchCachedWeatherForLocation == false)
        #expect(persistenceService.didCallUpdateCacheForFreshWeather == false)
        #expect(persistenceService.didCallUpdateCacheForSummaries == false)
    }

    @Test("update location")
    mutating func updateLocation() async {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )

        let mockWeather = Weather.mock()
        let mockForecast = Forecast.mock()
        weatherService.currentWeatherResult = .success(mockWeather)
        weatherService.forecastWeatherResult = .success(mockForecast)

        let location = CachedLocation(
            name: "Nairobi",
            region: "",
            latitude: 1,
            longitude: 1
        )

        // act
        sut.updateLocation(to: location)

        // wait for a brief moment
        try? await Task.sleep(for: .milliseconds(100))

        // assert view model state
        #expect(sut.isLoading == false)
        #expect(sut.weather?.id == mockWeather.id)
        #expect(sut.dailySummaries.isEmpty == false)
        #expect(sut.dailySummaries.first?.main == mockForecast.list.first?.main)
        #expect(sut.lastUpdated == "Last Update: Now")
        #expect(sut.errorMessage == nil)

        // assert cache update
        #expect(persistenceService.didCallFetchCachedWeatherForLocation == true)
        #expect(persistenceService.didCallUpdateCacheForFreshWeather == true)
        #expect(persistenceService.freshWeather == sut.weather)
        #expect(persistenceService.didCallUpdateCacheForSummaries == true)
        #expect(persistenceService.summaries == sut.dailySummaries)
    }

    @Test("correctly convert and format temperature")
    mutating func testFormatTemperature() {
        sut = .init(
            geocoderService: geocoderService,
            locationManager: locationManager,
            persistenceService: persistenceService,
            service: weatherService
        )
        let key = "unit"

        #expect(sut.formatTemperature(nil) == "--")

        UserDefaults.standard.set(TemperatureUnit.celcius.rawValue, forKey: key)
        #expect(sut.formatTemperature(25.4) == "25°", "Should round off correctly")
        #expect(sut.formatTemperature(0) == "0°", "Should handle 0 celcius correctly")

        UserDefaults.standard.set(TemperatureUnit.fahrenheit.rawValue, forKey: key)
        #expect(sut.formatTemperature(25) == "77°", "Should convert 25 to 77")
        #expect(sut.formatTemperature(0) == "32°", "Should convert 0 to 32")
        #expect(sut.formatTemperature(-17.7) == "0°", "Should round fahrenheit correctly")

        UserDefaults.standard.removeObject(forKey: key)
    }
}
