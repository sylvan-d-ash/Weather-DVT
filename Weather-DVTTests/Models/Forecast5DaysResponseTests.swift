//
//  Forecast5DaysResponseTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

struct Forecast5DaysResponseTests {
    let decoder = JSONDecoder()

    @Test("Successfully decodes from valid forecast JSON")
    func testDecodingSuccess() throws {
        let jsonData = MockAPIData.forecast5DaysJSON

        // act
        let sut = try decoder.decode(Forecast5DaysResponse.self, from: jsonData)

        // assert
        #expect(sut.city.name == "Mountain View")
        #expect(sut.list.count == 2, "The list should contain 2 forecast items")
        #expect(sut.list.first?.date == 1661870592)
    }

    @Test("`toDomain` method maps the entire forecast object correctly")
    func testToDomainMapping() throws {
        let sut = try decoder.decode(Forecast5DaysResponse.self, from: MockAPIData.forecast5DaysJSON)

        // act
        let domainModel = sut.toDomain()

        // assert
        #expect(domainModel.city == "Mountain View")
        #expect(domainModel.list.count == 2)

        // Spot-check the first mapped item to ensure the nested mapping worked
        let firstItem = domainModel.list.first
        #expect(firstItem?.main == "Atmosphere")
        #expect(firstItem?.currentTempInCelcius == 25.45)
    }
}
