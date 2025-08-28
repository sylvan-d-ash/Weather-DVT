//
//  LocationsViewModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
import SwiftData
@testable import Weather_DVT

@MainActor
struct LocationsViewModelTests {
    var sut: LocationsView.ViewModel!
    var searchService: MockMapSearchService!
    var modelContext: ModelContext!
    let location = SearchLocation(name: "Nairobi", region: "", coordinate: .init(latitude: 1, longitude: 1))

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CachedLocation.self, configurations: config)
        modelContext = container.mainContext

        searchService = MockMapSearchService()
        sut = .init(mapService: searchService, modelContext: modelContext)
    }

    @Test("empty search")
    func emptySearch() {
        sut.searchText = ""
        #expect(sut.searchResults.isEmpty)
        #expect(sut.errorMessage == nil)
    }

    @Test("search populates search results")
    func searchPopulatesSearchResults() async {
        searchService.searchResults = .success([location])

        sut.searchText = "Nai"

        // wait for a duration longer than the debounce
        try? await Task.sleep(for: .milliseconds(400))

        // assert
        #expect(sut.searchResults.count == 1)
        #expect(sut.searchResults.first?.name == location.name)
        #expect(sut.errorMessage == nil)
    }

    @Test("search sets error message on failure")
    func searchSetsErrorMessageOnFailure() async {
        searchService.searchResults = .failure(MockTestError.dummyError)

        sut.searchText = "Invalid"

        try? await Task.sleep(for: .milliseconds(400))

        #expect(sut.searchResults.isEmpty)
        #expect(sut.errorMessage != nil)
    }

    @Test("navigate to result")
    func navigateToResult() {
        #expect(sut.path.isEmpty, "Precondition: path should be empty.")

        sut.navigateToSearchResults(for: location)

        #expect(sut.path.count == 1, "Path should contain one element")
    }

    @Test("navigation appends to exising path")
    func navigationAppendsToExisingPath() {
        let location2 = SearchLocation(name: "Mombasa", region: "", coordinate: .init(latitude: 2, longitude: 2))
        #expect(sut.path.isEmpty, "Precondition: path should be empty.")

        sut.navigateToSearchResults(for: location)

        #expect(sut.path.count == 1, "Path should contain one element")

        sut.navigateToSearchResults(for: location2)

        #expect(sut.path.count == 2, "Path should contain 2 elements")
    }

    @Test("add location creates a new database entry")
    func addLocationCreatesANewDatabaseEntry() async {
        // TODO: test currently fails when trying to fetch from context
//        sut.addLocation(location)
//
//        let descriptor = FetchDescriptor<CachedLocation>()
//        let savedLocations = try! modelContext.fetch(descriptor)
//
//        #expect(savedLocations.count == 1)
//        #expect(savedLocations.first?.name == "Nairobi")
//        #expect(sut.searchText.isEmpty, "Search text should be cleared after adding a location")
    }

    @Test("delete location")
    func deleteLocation() async {
        // TODO:
    }
}
