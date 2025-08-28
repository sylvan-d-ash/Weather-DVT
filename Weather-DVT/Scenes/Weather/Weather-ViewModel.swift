//
//  Weather-ViewModel.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Combine
import Foundation
import SwiftUI

extension WeatherView {
    @MainActor
    final class ViewModel: ObservableObject {
        @AppStorage("theme") private var selectedTheme: Theme = .forest
        @AppStorage("unit") private var selectedUnit: TemperatureUnit = .celcius

        @Published private(set) var weather: Weather?
        @Published private(set) var dailySummaries: [Weather] = []
        @Published private(set) var isLoading = false
        @Published private(set) var isUpdatingCache = false
        @Published private(set) var errorMessage: String?
        @Published private(set) var lastUpdated: String?

        @Published private(set) var location: WeatherLocation?

        var backgroundColor: Color {
            weather?.condition.backgroundColor(base: selectedTheme.base) ?? .rainy
        }

        var backgroundImage: String {
            weather?.condition.backgroundImage(base: selectedTheme.base) ?? "forest_rainy"
        }

        var locationName: String {
            location?.name ?? "--"
        }

        private var locationManager: UserLocationManager?
        private var persistenceService: PersistenceService?
        private let service: WeatherService
        private var cancellables = Set<AnyCancellable>()

        init(
            locationManager: UserLocationManager? = nil,
            persistenceService: PersistenceService? = nil,
            service: WeatherService = DefaultWeatherService(),
            searchResult: SearchLocation? = nil
        ) {
            self.locationManager = locationManager
            self.persistenceService = persistenceService
            self.service = service

            if locationManager != nil {
                bindLocation()
            }

            if let searchResult = searchResult {
                self.location = WeatherLocation(from: searchResult)

                Task { await loadWeather() }
            }
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

        func updateLocation(to location: CachedLocation) {
            self.location = WeatherLocation(from: location)

            Task { await loadWeather() }
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
            isUpdatingCache = location.kind != .temporary

            // check cache based on location kind
            if let cachedLocation = persistenceService?.fetchCachedWeather(for: location),
               let cachedWeather = cachedLocation.weather {
                loadCachedWeather(from: cachedLocation, with: cachedWeather)
                isLoading = false
            }

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
            isUpdatingCache = false

            switch current {
            case .success(let weather):
                self.weather = weather
                persistenceService?.updateCache(for: location, with: weather)
                lastUpdated = "Last Update: Now"
            case .failure(let error):
                errorMessage = error.localizedDescription
            }

            switch forecast {
            case .success(let forecast):
                getDailySummaries(from: forecast)
                persistenceService?.updateCache(for: location, with: dailySummaries)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }

        private func loadCachedWeather(from cache: CachedLocation, with cachedWeather: CachedCurrentWeather) {
            weather = Weather(from: cachedWeather)
            dailySummaries = cache.forecast
                .map { Weather(from: $0) }
                .sorted { $0.date < $1.date }

            if location?.kind != .temporary {
                let date = cache.date.formatted(date: .abbreviated, time: .shortened)
                lastUpdated = "Last Update: \(date)"
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
    }
}
