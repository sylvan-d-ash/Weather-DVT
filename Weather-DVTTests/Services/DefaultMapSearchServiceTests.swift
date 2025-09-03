//
//  DefaultMapSearchServiceTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import MapKit
import Testing
@testable import Weather_DVT

@MainActor
struct DefaultMapSearchServiceTests {
    var sut: DefaultMapSearchService!
    var mockSearch: MockMKLocalSearch!

    init() {
        // can't capture `self` in the init, so use a local constant instead
        let localSearch = MockMKLocalSearch()
        self.mockSearch = localSearch
        sut = DefaultMapSearchService(searchMaker: { _ in localSearch })
    }

    // MARK: - Test Cases

    @Test("Search returns a successfully mapped Airport")
    func testSearchReturnsAirport() async {
        let airportItem = MockMKLocalSearch.createMockMapItem(
            name: "JFK Airport",
            locality: "New York",
            administrativeArea: "NY",
            country: "USA",
            category: .airport
        )
        mockSearch.mockResponse = MockLocalSearchResponse(localMapItems: [airportItem])

        // act
        let result = await sut.search(for: "JFK")

        // assert
        switch result {
        case .success(let locations):
            #expect(locations.count == 1)
            #expect(locations.first?.name == "JFK Airport")
            #expect(locations.first?.region == "NY, USA")
        case .failure(let error):
            Issue.record("Search failed: \(error.localizedDescription)")
        }
    }

    @Test("Search returns a successfully mapped Town")
    func testSearchReturnsTown() async {
        let townItem = MockMKLocalSearch.createMockMapItem(
            name: "Cupertino",
            locality: "Cupertino",
            administrativeArea: "CA",
            country: "USA",
            category: .library
        )
        mockSearch.mockResponse = MockLocalSearchResponse(localMapItems: [townItem])

        // act
        let result = await sut.search(for: "Cupertino")

        // assert
        switch result {
        case .success(let locations):
            #expect(locations.count == 1)
            #expect(locations.first?.name == "Cupertino")
            #expect(locations.first?.region == "CA, USA")
        case .failure(let error):
            Issue.record("Search failed: \(error.localizedDescription)")
        }
    }

    @Test("Search filters out a specific street address")
    func testSearchFiltersOutStreetAddress() async {
        // A street address has both locality (city) AND thoroughfare (street)
        let streetItem = MockMKLocalSearch.createMockMapItem(
            name: "1 Infinite Loop",
            locality: "Cupertino",
            thoroughfare: "Infinite Loop",
            administrativeArea: "CA",
            country: "USA"
        )
        mockSearch.mockResponse = MockLocalSearchResponse(localMapItems: [streetItem])

        // act
        let result = await sut.search(for: "Apple")

        // The result should be success, but the list should be empty.
        switch result {
        case .success(let locations):
            #expect(locations.isEmpty)
        case .failure(let error):
            Issue.record("Search failed: \(error.localizedDescription)")
        }
    }

    @Test("Search filters out a random point of interest that is not an airport or town")
    func testSearchFiltersOutRandomPOI() async {
        // This POI has no locality (city), so it's not a town.
        let cafeItem = MockMKLocalSearch.createMockMapItem(
            name: "The Coffee Shop",
            administrativeArea: "CA",
            country: "USA",
            category: .cafe
        )
        mockSearch.mockResponse = MockLocalSearchResponse(localMapItems: [cafeItem])

        // act
        let result = await sut.search(for: "Coffee")

        // assert
        switch result {
        case .success(let locations):
            #expect(locations.isEmpty)
        case .failure(let error):
            Issue.record("Search failed: \(error.localizedDescription)")
        }
    }

    @Test("Search returns a failure when the underlying search throws an error")
    func testSearchReturnsFailureOnError() async {
        mockSearch.mockError = MockTestError.dummyError

        // act
        let result = await sut.search(for: "anything")

        // assert
        switch result {
        case .success:
            Issue.record("Search should have failed but it succeeded.")
        case .failure(let error):
            #expect(error is MockTestError, "The error should be the one we provided.")
        }
    }
}
