//
//  Weather-ViewModel.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI
import Foundation

extension WeatherView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var weather: Weather?
        @Published private(set) var dailySummaries: [Weather] = []
        @Published private(set) var isLoading = false
        @Published private(set) var errorMessage: String?

        var backgroundColor: Color {
            weather?.condition.backgroundColor ?? .sunny
        }

        var backgroundImage: String {
            weather?.condition.backgroundImage() ?? "forest_sunny"
        }

        private let service: WeatherService

        init(service: WeatherService = DefaultWeatherService()) {
            self.service = service
        }

        func loadWeather() async {
            isLoading = true
            errorMessage = nil

            async let currentWeatherResult = service.fetchCurrentWeather(lat: 33.55, lon: -7.62)
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

        func formatTemperature(_ temp: Double?) -> String {
            guard let temp = temp else { return "--" }
            return String(format: "%.0f°", temp)
        }

        private func getDailySummaries(from forecast: Forecast) {
            let grouped = Dictionary(grouping: forecast.list) { weather in
                Calendar.current.startOfDay(for: weather.date)
            }

            dailySummaries = grouped.compactMap { (day, weathers) -> Weather? in
                guard let first = weathers.first else { return nil }

                // get average min/max temps
                let minTemp = weathers.compactMap { $0.minTemperature ?? $0.currentTemperature }.min()
                let maxTemp = weathers.compactMap { $0.maxTemperature ?? $0.currentTemperature }.max()

                // get most frequent main
                let mainCounts = Dictionary(grouping: weathers, by: { $0.main })
                    .mapValues { $0.count }
                let mostFrequentMain = mainCounts.max(by: { $0.value < $1.value })?.key ?? first.main
                print(mostFrequentMain)

                return Weather(
                    date: day,
                    main: mostFrequentMain,
                    // average of min/max
                    currentTemperature: ((minTemp ?? 0) + (maxTemp ?? 0)) / 2,
                    minTemperature: minTemp,
                    maxTemperature: maxTemp
                )
            }.sorted(by: { $0.date < $1.date })
        }
    }
}
