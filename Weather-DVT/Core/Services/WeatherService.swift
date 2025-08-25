//
//  WeatherService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

enum WeatherEndpoint: APIEndpoint {
    case current(lat: Double, lon: Double)
    case forecast5Days(lat: Double, lon: Double)

    var path: String {
        switch self {
        case .current:
            return "/data/2.5/weather"
        case .forecast5Days:
            return "/data/2.5/forecast"
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .current(let lat, let lon), .forecast5Days(let lat, let lon):
            return [
                "lat": lat,
                "lon": lon,
                "units": "metric",
            ]
        }
    }
}

protocol WeatherService: AnyObject {
    func fetchCurrentWeather(lat: Double, lon: Double) async -> Result<Weather, Error>
    func fetch5DaysForecast(lat: Double, lon: Double) async -> Result<Forecast, Error>
}

final class DefaultWeatherService: WeatherService {
    private let networkService: NetworkService

    init(networkService: NetworkService = URLSessionNetworkService()) {
        self.networkService = networkService
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async -> Result<Weather, Error> {
        let result = await networkService.fetch(
            CurrentWeatherResponse.self,
            endpoint: WeatherEndpoint.current(lat: lat, lon: lon)
        )

        switch result {
        case .success(let response):
            return .success(response.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }

    func fetch5DaysForecast(lat: Double, lon: Double) async -> Result<Forecast, Error> {
        let result = await networkService.fetch(
            Forecast5DaysResponse.self,
            endpoint: WeatherEndpoint.forecast5Days(lat: lat, lon: lon)
        )

        switch result {
        case .success(let response):
            return .success(response.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }
}
