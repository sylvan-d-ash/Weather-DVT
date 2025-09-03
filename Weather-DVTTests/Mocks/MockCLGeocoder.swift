//
//  MockCLGeocoder.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import CoreLocation
@testable import Weather_DVT

final class MockCLGeocoder: CLGeocoderProtocol {
    var mockPlacemarks: [MockPlacemark]?
    var mockError: Error?

    func reverseGeocode(location: CLLocation) async throws -> [PlacemarkForCL] {
        if let mockError { throw mockError }
        return mockPlacemarks ?? []
    }
}
