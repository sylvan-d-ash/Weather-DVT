//
//  GeocoderService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import CoreLocation

protocol CLGeocoderProtocol {
    func reverseGeocodeLocation(_ location: CLLocation) async throws -> [CLPlacemark]
}

extension CLGeocoder: CLGeocoderProtocol {}

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
