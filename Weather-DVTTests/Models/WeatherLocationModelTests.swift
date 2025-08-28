//
//  WeatherLocationModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct WeatherLocationModelTests {
    @Test("initialize from coordinate")
    func initializeFromCoordinate() {
        let sut = WeatherLocation(from: .init(latitude: 1, longitude: 1))
        #expect(sut.id == "current")
        #expect(sut.latitude == 1)
        #expect(sut.longitude == 1)
        #expect(sut.kind == .current)
    }

    @Test("initialize from SearchLocation")
    func initializeFromSearchLocation() {
        let location = SearchLocation(
            name: "Nairobi",
            region: "",
            coordinate: .init(latitude: 1, longitude: 1)
        )

        let sut = WeatherLocation(from: location)

        #expect(sut.id == location.id.uuidString)
        #expect(sut.latitude == location.coordinate.latitude)
        #expect(sut.longitude == location.coordinate.longitude)
        #expect(sut.kind == .temporary)
    }

    @Test("initialize from CachedLocation")
    func initializeFromCachedLocation() {
        let location = CachedLocation(
            name: "Nairobi",
            region: "",
            latitude: 1,
            longitude: 1
        )

        let sut = WeatherLocation(from: location)

        #expect(sut.id == location.id.uuidString)
        #expect(sut.latitude == location.latitude)
        #expect(sut.longitude == location.longitude)
        #expect(sut.kind == .saved(persistenceModelID: location.id))
    }
}
