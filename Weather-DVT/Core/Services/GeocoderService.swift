//
//  GeocoderService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import CoreLocation

protocol PlacemarkProtocol {
    var locality: String? { get }
    var administrativeArea: String? { get }
}

extension CLPlacemark: PlacemarkProtocol {}

protocol CLGeocoderProtocol {
    func reverseGeocode(location: CLLocation) async throws -> [PlacemarkProtocol]
}

extension CLGeocoder: CLGeocoderProtocol {
    func reverseGeocode(location: CLLocation) async throws -> [PlacemarkProtocol] {
        return try await reverseGeocodeLocation(location)
    }
}

protocol GeocoderService: AnyObject {
    func locationDetails(for location: CLLocation) async -> (city: String, region: String)?
}

final class DefaultGeocoderService: GeocoderService {
    private let geocoder: CLGeocoderProtocol

    init(geocoder: CLGeocoderProtocol = CLGeocoder()) {
        self.geocoder = geocoder
    }

    func locationDetails(for location: CLLocation) async -> (city: String, region: String)? {
        return nil
    }
}
