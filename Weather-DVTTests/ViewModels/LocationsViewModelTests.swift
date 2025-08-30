//
//  LocationsViewModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct LocationsViewModelTests {
    var sut: LocationsView.ViewModel!
    var searchService: MockMapSearchService!
    var modelContext: MockModelContext!
    let location = SearchLocation(name: "Nairobi", region: "", coordinate: .init(latitude: 1, longitude: 1))

    init() {
        modelContext = MockModelContext()
        searchService = MockMapSearchService()
        sut = .init(mapService: searchService, modelContext: modelContext)
    }

    @Test("empty search")
    func testEmptySearch() async {
        sut.searchText = ""

        // wait for a duration longer than the debounce
        try? await Task.sleep(for: .milliseconds(400))

        #expect(sut.searchResults.isEmpty)
        #expect(sut.errorMessage == nil)
    }

    @Test("search populates search results")
    func testSearchPopulatesSearchResults() async {
        searchService.searchResults = .success([location])

        let query = "Nai"
        sut.searchText = query

        // wait for a duration longer than the debounce
        try? await Task.sleep(for: .milliseconds(400))

        // assert
        #expect(sut.searchResults.count == 1)
        #expect(sut.searchResults.first?.name == location.name)
        #expect(sut.errorMessage == nil)
        #expect(searchService.query == query)
    }

    @Test("search sets error message on failure")
    func testSearchSetsErrorMessageOnFailure() async {
        searchService.searchResults = .failure(MockTestError.dummyError)

        let query = "Invalid"
        sut.searchText = query

        try? await Task.sleep(for: .milliseconds(400))

        #expect(sut.searchResults.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(searchService.query == query)
    }

    @Test("navigate to result")
    func testNavigateToResult() {
        #expect(sut.path.isEmpty, "Precondition: path should be empty.")

        sut.navigateToSearchResults(for: location)

        #expect(sut.path.count == 1, "Path should contain one element")
    }

    @Test("navigation appends to exising path")
    func testNavigationAppendsToExisingPath() {
        let location2 = SearchLocation(name: "Mombasa", region: "", coordinate: .init(latitude: 2, longitude: 2))
        #expect(sut.path.isEmpty, "Precondition: path should be empty.")

        sut.navigateToSearchResults(for: location)

        #expect(sut.path.count == 1, "Path should contain one element")

        sut.navigateToSearchResults(for: location2)

        #expect(sut.path.count == 2, "Path should contain 2 elements")
    }

    @Test("add location creates a new unique database entry")
    func testAddLocationWhenUniqueEntry() {
        modelContext.mockCountResult = 0
        sut.searchText = "Nair"

        sut.addLocation(location)

        let inserted = modelContext.getInsertedObject(ofType: CachedLocation.self)
        #expect(sut.searchText == "", "Search text should be reset")
        #expect(sut.errorMessage == nil, "Error message should be nil on success")
        #expect(modelContext.didCallFetchCount)
        #expect(modelContext.didCallInsert)
        #expect(modelContext.didCallSave)
        #expect(inserted != nil, "A CachedLocation object should be inserted")
        #expect(inserted?.name == location.name)
    }

    @Test("add location does not create a duplicate")
    func testAddLocationWhenDuplicate() async {
        modelContext.mockCountResult = 1
        sut.searchText = "Nair"

        sut.addLocation(location)

        #expect(sut.searchText == "", "Search text should be reset")
        #expect(sut.errorMessage == nil, "Error message should be nil regardless")
        #expect(modelContext.didCallFetchCount)
        #expect(modelContext.didCallInsert == false)
        #expect(modelContext.didCallSave == false)
        #expect(modelContext.insertedObjects.isEmpty, "No object should be created when a duplicate is found")
    }

    @Test("add location sets error message when database action fails")
    func testAddLocationWhenDatabaseFails() {
        modelContext.shouldThrowOnFetchCountError = true
        sut.searchText = "Nair"

        sut.addLocation(location)

        #expect(sut.searchText == "Nair")
        #expect(sut.errorMessage != nil)
        #expect(modelContext.didCallFetchCount)
        #expect(modelContext.didCallInsert == false)
        #expect(modelContext.didCallSave == false)
        #expect(modelContext.insertedObjects.isEmpty)
    }

    @Test("delete locations removes the correct items")
    func testDeleteLocationsSuccess() async {
        let allLocations = [
            CachedLocation.mock(name: "Nairobi"),
            CachedLocation.mock(name: "Mumbai"),
            CachedLocation.mock(name: "Mombasa"),
        ]
        let offsets: IndexSet = [0, 2]

        sut.deleteLocations(at: offsets, from: allLocations)

        let deletedNames = modelContext.deleteObjects
            .compactMap { $0 as? CachedLocation }
            .map { $0.name }
        #expect(modelContext.didCallDelete)
        #expect(modelContext.didCallSave)
        #expect(deletedNames == ["Nairobi", "Mombasa"])
        #expect(modelContext.deleteObjects.count == 2)
        #expect(sut.errorMessage == nil)
    }

    @Test("delete locations sets error message when database action fails")
    func testDeleteLocationsFail() {
        modelContext.shouldThrowOnSaveError = true

        let offsets: IndexSet = [0]
        let allLocations = [CachedLocation.mock(name: "Nairobi")]
        sut.deleteLocations(at: offsets, from: allLocations)

        #expect(modelContext.didCallDelete)
        #expect(modelContext.didCallSave)
        #expect(sut.errorMessage != nil)
    }
}
