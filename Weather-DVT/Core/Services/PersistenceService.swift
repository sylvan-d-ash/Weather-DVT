//
//  PersistenceService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

protocol ModelContextProtocol {
    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T: PersistentModel
    func fetchCount<T>(_ descriptor: FetchDescriptor<T>) throws -> Int where T: PersistentModel
    func insert<T>(_ model: T) where T: PersistentModel
    func delete<T>(_ model: T) where T : PersistentModel
    func save() throws
}

extension ModelContext: ModelContextProtocol {}

@MainActor
protocol  PersistenceService {
    func fetchCachedWeather(for location: WeatherLocation) -> CachedLocation?
    func updateCache(for location: WeatherLocation, with freshWeather: Weather)
    func updateCache(for location: WeatherLocation, with summaries: [Weather])
}

@MainActor
final class DefaultPersistenceService: PersistenceService {
    private let modelContext: ModelContextProtocol

    init(modelContext: ModelContextProtocol) {
        self.modelContext = modelContext
    }

    func fetchCachedWeather(for location: WeatherLocation) -> CachedLocation? {
        return findOrCreateLocation(for: location)
    }

    func updateCache(for location: WeatherLocation, with freshWeather: Weather) {
        guard let locationToUpdate = findOrCreateLocation(for: location) else { return }

        // update or create a new CachedCurrentWeather
        if let cache = locationToUpdate.weather {
            cache.currentTempCelcius = freshWeather.currentTempInCelcius
            cache.minTempCelcius = freshWeather.minTempInCelcius
            cache.maxTempCelcius = freshWeather.maxTempInCelcius
            cache.main = freshWeather.main
            cache.lastUpdated = .now
        } else {
            let newCache = CachedCurrentWeather(
                currentTempCelcius: freshWeather.currentTempInCelcius,
                minTempCelcius: freshWeather.minTempInCelcius,
                maxTempCelcius: freshWeather.maxTempInCelcius,
                main: freshWeather.main
            )
            locationToUpdate.weather = newCache
        }

        try? modelContext.save()
    }

    func updateCache(for location: WeatherLocation, with summaries: [Weather]) {
        guard let locationToUpdate = findOrCreateLocation(for: location) else { return }

        // delete old forecasts to ensure no stale data
        locationToUpdate.forecast.removeAll()

        // create new CachedForecastWeather
        for summary in summaries {
            let forecast = CachedForecastWeather(
                currentTempCelcius: summary.currentTempInCelcius,
                minTempCelcius: summary.minTempInCelcius,
                maxTempCelcius: summary.maxTempInCelcius,
                main: summary.main,
                date: summary.date
            )
            forecast.location = locationToUpdate
            locationToUpdate.forecast.append(forecast)
        }

        try? modelContext.save()
    }

    private func findOrCreateLocation(for location: WeatherLocation) -> CachedLocation? {
        switch location.kind {
        case .temporary:
            // never save weather for search results
            return nil
        case .saved(let id):
            // use ID
            let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.id == id })
            return try? modelContext.fetch(descriptor).first
        case .current:
            // use unique flag
            let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.isCurrentUserLocation })
            if let currentLocation = try? modelContext.fetch(descriptor).first {
                return currentLocation
            } else {
                // create a new location
                let newLocation = CachedLocation(
                    name: "My Location", // TODO: reverse geocode
                    region: "",
                    latitude: location.latitude,
                    longitude: location.longitude,
                    isCurrentUserLocation: true
                )
                modelContext.insert(newLocation)
                return newLocation
            }
        }
    }
}
