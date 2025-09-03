//
//  MockModels.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
@testable import Weather_DVT

extension Weather {
    static func mock(main: String? = "clear") -> Weather {
        .init(
            date: .now,
            main: main,
            currentTempInCelcius: 25,
            minTempInCelcius: 19,
            maxTempInCelcius: 26
        )
    }
}

extension Forecast {
    static func mock() -> Forecast {
        .init(
            date: .now,
            city: "Nairobi",
            list: [
                Weather(
                    date: .now,
                    main: "clear",
                    currentTempInCelcius: 25,
                    minTempInCelcius: 19,
                    maxTempInCelcius: 26
                )
            ]
        )
    }
}

extension CachedLocation {
    static func mock(id: UUID = UUID(), name: String, isCurrent: Bool = false) -> CachedLocation {
        .init(
            id: id,
            name: name,
            region: "",
            latitude: 1,
            longitude: 1,
            isCurrentUserLocation: isCurrent
        )
    }
}

extension WeatherLocation {
    static func mock(kind: WeatherLocation.Kind) -> WeatherLocation {
        .init(
            id: UUID().uuidString,
            name: "Test",
            region: "",
            latitude: 1,
            longitude: 1,
            kind: kind
        )
    }
}

extension CachedCurrentWeather {
    static func mock() -> CachedCurrentWeather {
        .init(
            currentTempCelcius: 20,
            minTempCelcius: 18,
            maxTempCelcius: 23,
            main: "rainy"
        )
    }
}

extension CachedForecastWeather {
    static func mock() -> CachedForecastWeather {
        .init(
            currentTempCelcius: 19,
            minTempCelcius: 15,
            maxTempCelcius: 21,
            main: "clouds",
            date: .now
        )
    }
}

struct MockPlacemark: PlacemarkForCL {
    var locality: String?
    var administrativeArea: String?
}
