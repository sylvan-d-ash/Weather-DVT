//
//  WeatherResponse.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

private struct Weather: Decodable {
    let main: String
}

private struct Main: Decodable {
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
    fileprivate let weather: Weather
    fileprivate let main: Main
    let date: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case weather, main
        case date = "dt"
    }
}

struct Forecast5DaysResponse: Decodable {
    struct City: Decodable {
        let id: Int
        let name: String
    }

    let city: City
    let list: [CurrentWeatherResponse]
}
