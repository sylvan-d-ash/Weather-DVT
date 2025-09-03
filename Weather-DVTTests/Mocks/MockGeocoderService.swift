//
//  MockGeocoderService.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import CoreLocation
@testable import Weather_DVT

final class MockGeocoderService: GeocoderService {
    private(set) var didCallLocationDetails = false
    var mockDetails: (city: String, region: String?)?

    func locationDetails(for location: CLLocation) async -> (city: String, region: String?)? {
        didCallLocationDetails = true
        return mockDetails
    }
}
