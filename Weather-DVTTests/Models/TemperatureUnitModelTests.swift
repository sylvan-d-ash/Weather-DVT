//
//  TemperatureUnitModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct TemperatureUnitModelTests {
    @Test("id")
    func testId() {
        #expect(TemperatureUnit.celcius.id == "celcius")
        #expect(TemperatureUnit.fahrenheit.id == "fahrenheit")
    }

    @Test("name")
    func testName() {
        #expect(TemperatureUnit.celcius.name == "Celcius")
        #expect(TemperatureUnit.fahrenheit.name == "Fahrenheit")
    }

    @Test("symbol")
    func testSymbol() {
        #expect(TemperatureUnit.celcius.symbol == "°C")
        #expect(TemperatureUnit.fahrenheit.symbol == "°F")
    }
}
