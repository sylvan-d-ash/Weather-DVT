//
//  GeocoderServiceTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import Testing
import CoreLocation
@testable import Weather_DVT

@MainActor
struct GeocoderServiceTests {
    @Test("locationDetails successful lookup")
    func testSuccessfulLookup() async {
        let mockGeocoder = MockCLGeocoder()
        let placemark = MockPlacemark.create(city: "Nairobi", region: "Nairobi")
        mockGeocoder.mockPlacemarks = [placemark]

        let location = CLLocation(latitude: 1, longitude: 1)
        let sut = DefaultGeocoderService(geocoder: mockGeocoder)

        let details = await sut.locationDetails(for: location)

        #expect(details != nil)
        #expect(details?.city == "Nairobi")
        #expect(details?.region == "Nairobi")
    }
}
