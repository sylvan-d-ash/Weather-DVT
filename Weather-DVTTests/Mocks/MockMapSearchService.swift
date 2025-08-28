//
//  MockMapSearchService.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
@testable import Weather_DVT

final class MockMapSearchService: MapSearchService {
    private(set) var query: String?
    var searchResults: Result<[SearchLocation], Error> = .failure(MockTestError.notImplemented)

    func search(for query: String) async -> Result<[SearchLocation], any Error> {
        self.query = query
        return searchResults
    }
}
