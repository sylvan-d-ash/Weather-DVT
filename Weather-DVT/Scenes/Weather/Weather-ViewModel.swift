//
//  Weather-ViewModel.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

extension WeatherView {
    @MainActor
    final class ViewModel: ObservableObject {
        @AppStorage("theme") private var selectedTheme: Theme = .forest
        @AppStorage("unit") private var selectedUnit: TemperatureUnit = .celcius

        @Published private(set) var weather: Weather?
        @Published private(set) var dailySummaries: [Weather] = []
        @Published private(set) var isLoading = false
        @Published private(set) var errorMessage: String?

        @Published private(set) var location: WeatherLocation?

        var backgroundColor: Color {
            weather?.condition.backgroundColor(base: selectedTheme.base) ?? .rainy
        }

        var backgroundImage: String {
            weather?.condition.backgroundImage(base: selectedTheme.base) ?? "forest_rainy"
        }

        private var locationManager: LocationManager?
        private var modelContext: ModelContext?
        private let service: WeatherService
        private var cancellables = Set<AnyCancellable>()

        init(locationManager: LocationManager, modelContext: ModelContext, service: WeatherService = DefaultWeatherService()) {
            self.locationManager = locationManager
            self.modelContext = modelContext
            self.service = service

            bindLocation()
        }

        init(service: WeatherService = DefaultWeatherService(), result: SearchLocation) {
            self.service = service
            self.location = WeatherLocation(from: result)

            Task { await loadWeather() }
        }

        func requestAuthorization() {
            locationManager?.requestAuthorization()
        }

        func formatTemperature(_ celcius: Double?) -> String {
            guard let celcius = celcius else { return "--" }

            let converted: Double
            switch selectedUnit {
            case .celcius: converted = celcius
            case .fahrenheit: converted = (celcius * 9.0 / 5.0) + 32.0
            }

            return String(format: "%.0f°", converted)
        }

        private func bindLocation() {
            guard let locationManager else { return }
            locationManager.locationPublisher
                .compactMap { $0 }
                .sink { [weak self] coordinate in
                    self?.location = WeatherLocation(from: coordinate)
                    Task { await self?.loadWeather() }
                }
                .store(in: &cancellables)

            locationManager.authorizationStatusPublisher
                .sink { [weak self] status in
                    switch status {
                    case .authorizedAlways, .authorizedWhenInUse:
                        self?.locationManager?.requestLocation()
                    case .denied, .restricted:
                        self?.errorMessage = "Location access denied. Please enable it in Settings."
                    case .notDetermined:
                        break
                    @unknown default:
                        break
                    }
                }
                .store(in: &cancellables)

            locationManager.errorMessagePublisher
                .sink { [weak self] message in
                    self?.errorMessage = message
                }
                .store(in: &cancellables)
        }

        private func loadWeather() async {
            guard let location else { return }

            isLoading = true
            errorMessage = nil

            // check cache based on location kind
            if let cachedLocation = loadCachedWeather(for: location), let cachedWeather = cachedLocation.weather {
                self.weather = Weather(from: cachedWeather)
                self.dailySummaries = cachedLocation.forecast
                    .map { Weather(from: $0) }
                    .sorted { $0.date < $1.date }
                self.isLoading = false
            }

            // TODO: show updating cached progress view
            // fetch fresh data from API
            async let currentWeatherResult = service.fetchCurrentWeather(
                lat: location.latitude,
                lon: location.longitude
            )
            async let forecastResult = service.fetch5DaysForecast(
                lat: location.latitude,
                lon: location.longitude
            )

            let (current, forecast) = await (currentWeatherResult, forecastResult)
            isLoading = false

            switch current {
            case .success(let weather):
                self.weather = weather
                updateCache(for: location, with: weather)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }

            switch forecast {
            case .success(let forecast):
                getDailySummaries(from: forecast)
                updateCache(for: location, with: dailySummaries)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }

        private func getDailySummaries(from forecast: Forecast) {
            let grouped = Dictionary(grouping: forecast.list) { weather in
                Calendar.current.startOfDay(for: weather.date)
            }

            dailySummaries = grouped.compactMap { (day, weathers) -> Weather? in
                guard let first = weathers.first else { return nil }

                // get average min/max temps
                let minTemp = weathers.compactMap { $0.minTempInCelcius ?? $0.currentTempInCelcius }.min()
                let maxTemp = weathers.compactMap { $0.maxTempInCelcius ?? $0.currentTempInCelcius }.max()

                // get most frequent main
                let mainCounts = Dictionary(grouping: weathers, by: { $0.main })
                    .mapValues { $0.count }
                let mostFrequentMain = mainCounts.max(by: { $0.value < $1.value })?.key ?? first.main

                return Weather(
                    date: day,
                    main: mostFrequentMain,
                    // average of min/max
                    currentTempInCelcius: ((minTemp ?? 0) + (maxTemp ?? 0)) / 2,
                    minTempInCelcius: minTemp,
                    maxTempInCelcius: maxTemp
                )
            }.sorted(by: { $0.date < $1.date })
        }

        private func loadCachedWeather(for location: WeatherLocation) -> CachedLocation? {
            switch location.kind {
            case .temporary:
                // temporary locations (from search results) never have cached data
                return nil
            case .saved(let id):
                // for a favourite, find it by its ID
                let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.id == id })
                return try? modelContext?.fetch(descriptor).first
            case .current:
                // for current location, find it using the unique flag
                let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.isCurrentUserLocation })
                return try? modelContext?.fetch(descriptor).first
            }
        }

        private func updateCache(for location: WeatherLocation, with freshWeather: Weather) {
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

            try? modelContext?.save()
        }

        private func updateCache(for location: WeatherLocation, with summaries: [Weather]) {
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
        }

        private func findOrCreateLocation(for location: WeatherLocation) -> CachedLocation? {
            switch location.kind {
            case .temporary:
                // never save weather for search results
                return nil
            case .saved(let id):
                // use ID
                let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.id == id })
                return try? modelContext?.fetch(descriptor).first
            case .current:
                // use unique flag
                let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.isCurrentUserLocation })
                if let currentLocation = try? modelContext?.fetch(descriptor).first {
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
                    modelContext?.insert(newLocation)
                    return newLocation
                }
            }
        }
    }
}
