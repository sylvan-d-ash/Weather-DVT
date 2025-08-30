//
//  DefaultPersistenceServiceTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct DefaultPersistenceServiceTests {
    var sut: DefaultPersistenceService!
    var mockModelContext: MockModelContext!

    init() {
        mockModelContext = MockModelContext()
        sut = DefaultPersistenceService(modelContext: mockModelContext)
    }

    @Test("findOrCreateLocation returns nil for temporary locations")
    func testFindForTemporaryLocation() {
        let tempLocation = WeatherLocation.mock(kind: .temporary)

        // act
        let result = sut.fetchCachedWeather(for: tempLocation)

        // assert
        #expect(result == nil, "Should return nil for temporary locations")
        #expect(mockModelContext.insertedObjects.isEmpty, "Should not insert anything for a temporary location")
    }

    @Test("findOrCreateLocation fetches and returns an existing 'saved' location")
    func testFindForExistingSavedLocation() {
        let locationID = UUID()
        let savedLocation = WeatherLocation.mock(kind: .saved(persistenceModelID: locationID))
        let existingCache = CachedLocation.mock(id: locationID, name: "Test")
        mockModelContext.mockFetchResult = [existingCache]

        // act
        let result = sut.fetchCachedWeather(for: savedLocation)

        // assert
        #expect(result?.id == locationID, "Should return the fetched location")
        #expect(mockModelContext.didCallFetch)
        #expect(mockModelContext.insertedObjects.isEmpty, "Should not insert a new location for saved location")
    }

    @Test("findOrCreateLocation fetches and returns an existing 'current' location")
    func testFindForExistingCurrentLocation() {
        let currentLocation = WeatherLocation.mock(kind: .current)
        let existingCache = CachedLocation.mock(name: "Test", isCurrent: true)
        mockModelContext.mockFetchResult = [existingCache]

        // act
        let result = sut.fetchCachedWeather(for: currentLocation)

        // assert
        #expect(result?.isCurrentUserLocation == true, "Should return the correct 'current' location")
        #expect(mockModelContext.didCallFetch)
        #expect(mockModelContext.insertedObjects.isEmpty, "Should not insert a new location if one is found")
    }

    @Test("findOrCreateLocation CREATES a 'current' location if none exists")
    func testCreate_ForNewCurrentLocation() {
        let currentLocation = WeatherLocation.mock(kind: .current)
        mockModelContext.mockFetchResult = []

        // act
        let result = sut.fetchCachedWeather(for: currentLocation)

        // assert
        let inserted = mockModelContext.getInsertedObject(ofType: CachedLocation.self)
        #expect(result != nil, "A new location should have been created and returned")
        #expect(mockModelContext.didCallFetch)
        #expect(mockModelContext.didCallInsert)
        #expect(mockModelContext.insertedObjects.count == 1, "A new location should have been inserted into the context")
        #expect(inserted?.isCurrentUserLocation == true, "The new location should be marked as the current user's location")
        #expect(inserted?.latitude == currentLocation.latitude)
        #expect(inserted?.longitude == currentLocation.longitude)
    }

    @Test("updateCache for weather updates an existing cache entry")
    func testUpdateCacheCurrentWeatherUpdatesExisting() {
        let location = WeatherLocation.mock(kind: .current)
        let existingWeather = CachedCurrentWeather.mock()
        let existingCache = CachedLocation.mock(name: "Test")
        existingCache.weather = existingWeather
        mockModelContext.mockFetchResult = [existingCache]

        let freshWeather = Weather.mock()

        // act
        sut.updateCache(for: location, with: freshWeather)

        // assert
        #expect(existingCache.weather?.currentTempCelcius == freshWeather.currentTempInCelcius, "The temperature should be updated to the new value")
        #expect(existingCache.weather?.main == freshWeather.main, "The condition should be updated")
        #expect(mockModelContext.didCallSave, "The context should be saved after updating")
    }

    @Test("updateCache for weather creates a new entry")
    func testUpdateCacheCurrentWeatherCreatesNew() {
        let location = WeatherLocation.mock(kind: .current)
        let existingCache = CachedLocation.mock(name: "Test")
        mockModelContext.mockFetchResult = [existingCache]

        let freshWeather = Weather.mock()

        // act
        sut.updateCache(for: location, with: freshWeather)

        // assert
        #expect(existingCache.weather?.currentTempCelcius == freshWeather.currentTempInCelcius, "The temperature should be updated to the new value")
        #expect(existingCache.weather?.main == freshWeather.main, "The condition should be updated")
        #expect(mockModelContext.didCallSave, "The context should be saved after updating")
    }

    @Test("updateCache for forecast updates existing forecast")
    func testUpdateCacheForecastReplacesExisting() {
        let location = WeatherLocation.mock(kind: .current)
        let oldForecastDay = CachedForecastWeather.mock()
        let existingCache = CachedLocation.mock(name: "Test")
        existingCache.forecast = [oldForecastDay]
        mockModelContext.mockFetchResult = [existingCache]

        let newForecastSummaries = [
            Weather.mock(main: "thunderstorm"),
            Weather.mock(main: "clear")
        ]

        // act
        sut.updateCache(for: location, with: newForecastSummaries)

        // assert
        #expect(existingCache.forecast.count == 2, "The forecast should now contain 2 new items")
        #expect(existingCache.forecast.first?.main == "thunderstorm", "The first forecast item should be the new data")
        #expect(existingCache.forecast.contains(where: { $0.main == oldForecastDay.main }) == false, "The old forecast data should be gone")
        #expect(mockModelContext.didCallSave, "The context should be saved after updating")
    }
}
