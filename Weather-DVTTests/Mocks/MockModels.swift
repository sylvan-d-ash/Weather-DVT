//
//  MockModels.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
@testable import Weather_DVT

extension Weather {
    static func mock() -> Weather {
        .init(
            date: .now,
            main: "clear",
            currentTempInCelcius: 25,
            minTempInCelcius: 19,
            maxTempInCelcius: 26
        )
    }

    static func mock(main: String?) -> Weather {
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
    static func mock(name: String) -> CachedLocation {
        .init(
            name: name,
            region: "",
            latitude: 1,
            longitude: 1
        )
    }
}
