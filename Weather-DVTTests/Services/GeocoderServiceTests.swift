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
    let sut: DefaultGeocoderService!
    let geocoder: MockCLGeocoder!

    init() {
        geocoder = MockCLGeocoder()
        sut = DefaultGeocoderService(geocoder: geocoder)
    }

    @Test("locationDetails successful lookup")
    func testSuccessfulLookup() async {
        let location = CLLocation(latitude: 1, longitude: 1)
        let placemark = MockPlacemark(locality: "Nairobi", administrativeArea: "Nairobi")
        geocoder.mockPlacemarks = [placemark]

        let details = await sut.locationDetails(for: location)

        #expect(details != nil)
        #expect(details?.city == "Nairobi")
        #expect(details?.region == "Nairobi")
    }

    @Test("locationDetails returns nil for failed lookup")
    func testFailedLookup() async {
        let location = CLLocation(latitude: 1, longitude: 1)
        geocoder.mockError = MockTestError.dummyError

        let details = await sut.locationDetails(for: location)

        #expect(details == nil)
    }

    @Test("locationDetails returns nil if placemark is missing essential data")
    func testMissingEssentialData() async {
        let location = CLLocation(latitude: 1, longitude: 1)
        let placemark = MockPlacemark(locality: nil, administrativeArea: "Nairobi")
        geocoder.mockPlacemarks = [placemark]

        let details = await sut.locationDetails(for: location)

        #expect(details == nil)
    }
}
