//
//  MockMKLocalSearch.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import MapKit
@testable import Weather_DVT

struct MockMapPlacemark: Placemark {
    var locality: String? = nil
    var thoroughfare: String? = nil
    var administrativeArea: String? = nil
    var country: String? = nil
    var coordinate: CLLocationCoordinate2D
}

struct MockMapItem: MapItem {
    var name: String?
    var localPlacemark: Placemark
    var pointOfInterestCategory: MKPointOfInterestCategory?
}

struct MockLocalSearchResponse: LocalSearchResponse {
    var localMapItems: [MapItem]
}

final class MockMKLocalSearch: MKLocalSearchProtocol {
    var mockResponse: MockLocalSearchResponse?
    var mockError: Error?

    func localStart() async throws -> LocalSearchResponse {
        if let mockError {
            throw mockError
        }
        guard let mockResponse else {
            return MockLocalSearchResponse(localMapItems: [])
        }
        return mockResponse
    }

    static func createMockMapItem(
        name: String,
        locality: String? = nil,
        thoroughfare: String? = nil,
        administrativeArea: String? = nil,
        country: String? = nil,
        coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0),
        category: MKPointOfInterestCategory? = nil
    ) -> MockMapItem {
        let placemark = MockMapPlacemark(
            locality: locality,
            thoroughfare: thoroughfare,
            administrativeArea: administrativeArea,
            country: country,
            coordinate: coordinate
        )

        let mapItem = MockMapItem(
            name: name,
            localPlacemark: placemark,
            pointOfInterestCategory: category
        )

        return mapItem
    }
}
