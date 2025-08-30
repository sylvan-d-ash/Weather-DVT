//
//  MockAPIData.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation

struct MockAPIData {

    static let currentWeatherJSON = """
    {
        "weather": [
            {
                "main": "Snow",
                "description": "clear sky",
                "icon": "01d"
            }
        ],
        "main": {
            "temp": 25.45,
            "temp_min": 22.1,
            "temp_max": 28.9
        },
        "dt": 1661870592
    }
    """.data(using: .utf8)!

    // An edge case to test `weather.first?` logic
    static let currentWeatherEmptyWeatherArrayJSON = """
    {
        "weather": [],
        "main": {
            "temp": 15.0,
            "temp_min": 12.0,
            "temp_max": 18.0
        },
        "dt": 1661870600
    }
    """.data(using: .utf8)!

    static let forecast5DaysJSON = """
    {
        "city": {
            "id": 123,
            "name": "Mountain View"
        },
        "list": [
            {
                "dt": 1661870592,
                "main": { "temp": 25.45, "temp_min": 22.1, "temp_max": 28.9 },
                "weather": [{ "main": "Atmosphere" }]
            },
            {
                "dt": 1661956992,
                "main": { "temp": 18.2, "temp_min": 15.0, "temp_max": 20.5 },
                "weather": [{ "main": "Drizzle" }]
            }
        ]
    }
    """.data(using: .utf8)!
}
