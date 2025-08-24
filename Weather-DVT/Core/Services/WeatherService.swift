//
//  WeatherService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

enum WeatherEndpoint: APIEndpoint {
    case current
    case forecast5Days

    var path: String {
        // TODO
        switch self {
        case .current:
            return "/data/2.5/weather"
        case .forecast5Days:
            return "/data/2.5/forecast"
        }
    }

    var parameters: [String : Any]? {
        // TODO
        switch self {
        case .current:
            return ["q": "Paris"]
        case .forecast5Days:
            return ["q": "Paris"]
        }
    }
}

protocol WeatherService: AnyObject {
    func fetchCurrentWeather() async -> Result<Weather, Error>
    func fetch5DaysForecast() async -> Result<String, Error> // TODO
}

final class DefaultWeatherService: WeatherService {
    private let networkService: NetworkService

    init(networkService: NetworkService = URLSessionNetworkService()) {
        self.networkService = networkService
    }

    func fetchCurrentWeather() async -> Result<Weather, Error> {
        let result = await networkService.fetch(CurrentWeatherResponse.self ,endpoint: WeatherEndpoint.current)

        switch result {
        case .success(let response):
            return .success(response.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }

    func fetch5DaysForecast() async -> Result<String, Error> {
        return await networkService.fetch(String.self, endpoint: WeatherEndpoint.forecast5Days)
    }
}
