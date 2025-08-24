//
//  WeatherResponse.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

private struct WeatherResponse: Decodable {
    let main: String
}

private struct MainResponse: Decodable {
    let temp: Double
    let max: Double?
    let min: Double?

    private enum CodingKeys: String, CodingKey {
        case temp
        case max = "temp_max"
        case min = "temp_min"
    }
}

struct CurrentWeatherResponse: Decodable {
    fileprivate let weather: WeatherResponse
    fileprivate let main: MainResponse
    let date: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case weather, main
        case date = "dt"
    }

    func toDomain() -> Weather {
        Weather(
            date: Date(timeIntervalSince1970: date),
            condition: weather.main,
            currentTemperature: main.temp,
            minTemperature: main.min,
            maxTemperature: main.max
        )
    }
}

struct Forecast5DaysResponse: Decodable {
    struct City: Decodable {
        let id: Int
        let name: String
    }

    let city: City
    let list: [CurrentWeatherResponse]

    func toDomain() -> Forecast {
        Forecast(
            date: .now,
            city: city.name,
            list: list.map { $0.toDomain() }
        )
    }
}
