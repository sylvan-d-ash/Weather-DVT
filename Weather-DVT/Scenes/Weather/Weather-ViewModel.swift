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
            guard let condition = weather?.condition else {
                return Color.sunny
            }

            switch condition {
            case "sunny": return .sunny
            case "rainy": return .rainy
            case "cloudy": return .cloudy
            default: return .sunny
            }
        }

        var backgroundImage: String {
            let base = "forest_"
            guard let condition = weather?.condition else {
                return base + "sunny"
            }

            switch condition {
            case "sunny": return base + "sunny"
            case "rainy": return base + "rainy"
            case "cloudy": return base + "cloudy"
            default: return base + "sunny"
            }
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
    }
}
