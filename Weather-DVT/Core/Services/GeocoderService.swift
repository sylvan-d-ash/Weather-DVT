//
//  GeocoderService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 03/09/2025.
//

import Foundation
import CoreLocation

// MARK: - CLPlacemark
protocol PlacemarkForCL {
    var locality: String? { get }
    var administrativeArea: String? { get }
}

extension CLPlacemark: PlacemarkForCL {}

// MARK: - CLGeocoder
protocol CLGeocoderProtocol {
    func reverseGeocode(location: CLLocation) async throws -> [PlacemarkForCL]
}

extension CLGeocoder: CLGeocoderProtocol {
    func reverseGeocode(location: CLLocation) async throws -> [PlacemarkForCL] {
        return try await reverseGeocodeLocation(location)
    }
}

// MARK: - GeocoderService
protocol GeocoderService: AnyObject {
    func locationDetails(for location: CLLocation) async -> (city: String, region: String?)?
}

final class DefaultGeocoderService: GeocoderService {
    private let geocoder: CLGeocoderProtocol

    init(geocoder: CLGeocoderProtocol = CLGeocoder()) {
        self.geocoder = geocoder
    }

    func locationDetails(for location: CLLocation) async -> (city: String, region: String?)? {
        do {
            let placemarks = try await geocoder.reverseGeocode(location: location)
            guard let placemark = placemarks.first, let city = placemark.locality else { return nil }
            return (city, placemark.administrativeArea)
        } catch {
            print("[GEOCODER] Error geocoding location: \(error.localizedDescription)")
            return nil
        }
    }
}
