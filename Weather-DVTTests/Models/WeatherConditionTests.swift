//
//  WeatherConditionTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import SwiftUI
import Testing
@testable import Weather_DVT

@MainActor
struct WeatherConditionTests {
    let sunny = Weather.Condition.sunny
    let rainy = Weather.Condition.rainy
    let cloudy = Weather.Condition.cloudy

    @Test("'text' returns the correct uppercase string")
    func textUppercase() {
        #expect(sunny.text == "SUNNY")
        #expect(rainy.text == "RAINY")
        #expect(cloudy.text == "CLOUDY")
    }

    @Test("'icon' returns the correct asset name")
    func iconName() {
        #expect(sunny.icon == "clear")
        #expect(rainy.icon == "rain")
        #expect(cloudy.icon == "partlysunny")
    }

    @Test("'backgroundColor' returns the correct color")
    func backgroundColor() {
        #expect(sunny.backgroundColor() == Color("forest_sunny"))
        #expect(rainy.backgroundColor() == Color.rainy)
        #expect(cloudy.backgroundColor() == Color("forest_cloudy"))

        let sea = "sea_"
        #expect(sunny.backgroundColor(base: sea) == Color("sea_sunny"))
        #expect(rainy.backgroundColor(base: sea) == Color.rainy)
        #expect(cloudy.backgroundColor(base: sea) == Color("sea_cloudy"))
    }

    @Test("'backgroundImage' returns correct asset name")
    func backgroundImage() {
        #expect(sunny.backgroundImage() == "forest_sunny")
        #expect(rainy.backgroundImage() == "forest_rainy")
        #expect(cloudy.backgroundImage() == "forest_cloudy")

        let sea = "sea_"
        #expect(sunny.backgroundImage(base: sea) == "sea_sunny")
        #expect(rainy.backgroundImage(base: sea) == "sea_rainy")
        #expect(cloudy.backgroundImage(base: sea) == "sea_cloudy")
    }
}
