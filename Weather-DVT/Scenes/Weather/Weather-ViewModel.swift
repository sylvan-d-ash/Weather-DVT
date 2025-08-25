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
        @Published private(set) var forecast: Forecast?
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
                self.forecast = forecast
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }

        func formatTemperature(_ temp: Double?) -> String {
            guard let temp = temp else { return "--" }
            return String(format: "%.0f°", temp)
        }
    }
}
