//
//  CurrentWeatherResponseTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

struct CurrentWeatherResponseTests {
    let decoder = JSONDecoder()

    @Test("Successfully decodes from valid JSON")
    func testDecodingSuccess() throws {
        let sut = try decoder.decode(
            CurrentWeatherResponse.self,
            from: MockAPIData.currentWeatherJSON
        )
        #expect(sut.date == 1661870592)
    }

    @Test("`toDomain` method maps all properties correctly")
    func testToDomainMapping() throws {
        let sut = try decoder.decode(
            CurrentWeatherResponse.self,
            from: MockAPIData.currentWeatherJSON
        )

        // act
        let domainModel = sut.toDomain()

        // assert
        #expect(domainModel.main == "Snow")
        #expect(domainModel.currentTempInCelcius == 25.45)
        #expect(domainModel.minTempInCelcius == 22.1)
        #expect(domainModel.maxTempInCelcius == 28.9)
        #expect(domainModel.date == Date(timeIntervalSince1970: 1661870592))
    }

    @Test("`toDomain` handles an empty weather array gracefully")
    func testToDomainEmptyWeatherArray() throws {
        // use the edge-case JSON
        let sut = try decoder.decode(
            CurrentWeatherResponse.self,
            from: MockAPIData.currentWeatherEmptyWeatherArrayJSON
        )

        // act
        let domainModel = sut.toDomain()

        // assert
        #expect(domainModel.main == nil, "The main condition should be nil when the weather array is empty")
    }
}
