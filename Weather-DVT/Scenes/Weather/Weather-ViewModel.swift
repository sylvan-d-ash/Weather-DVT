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
        @Published private(set) var errorMessage: String?

        var backgroundColor: Color {
            weather?.condition.backgroundColor(base: selectedTheme.base) ?? .rainy
        }

        var backgroundImage: String {
            weather?.condition.backgroundImage(base: selectedTheme.base) ?? "forest_rainy"
        }

        private let service: WeatherService
        private let locationManager: LocationManager
        private var cancellables = Set<AnyCancellable>()

        init(service: WeatherService = DefaultWeatherService(), locationManager: LocationManager) {
            self.service = service
            self.locationManager = locationManager

            bindLocation()
        }

        init(
            service: WeatherService = DefaultWeatherService(),
            locationManager: LocationManager,
            result: SearchLocation
        ) {
            self.service = service
            self.locationManager = locationManager

            Task {
                let coordinate = result.coordinate
                await loadWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            }
        }

        func requestAuthorization() {
            locationManager.requestAuthorization()
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
            locationManager.locationPublisher
                .compactMap { $0 }
                .sink { [weak self] coordinate in
                    Task {
                        await self?.loadWeather(lat: coordinate.latitude, lon: coordinate.longitude)
                    }
                }
                .store(in: &cancellables)

            locationManager.authorizationStatusPublisher
                .sink { [weak self] status in
                    switch status {
                    case .authorizedAlways, .authorizedWhenInUse:
                        self?.locationManager.requestLocation()
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

        private func loadWeather(lat: Double, lon: Double) async {
            isLoading = true
            errorMessage = nil

            async let currentWeatherResult = service.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecastResult = service.fetch5DaysForecast(lat: 33.55, lon: -7.62)

            let (current, forecast) = await (currentWeatherResult, forecastResult)
            isLoading = false

            switch current {
            case .success(let weather):
                self.weather = weather
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }

            switch forecast {
            case .success(let forecast):
                getDailySummaries(from: forecast)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
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
