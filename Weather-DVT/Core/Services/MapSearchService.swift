//
//  MapSearchService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import Foundation
import MapKit

protocol MapSearchService: AnyObject {
    func search(for query: String) async -> Result<[SearchLocation], Error>
}

final class DefaultMapSearchService: MapSearchService {
    func search(for query: String) async -> Result<[SearchLocation], any Error> {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            let results = response.mapItems.compactMap { item -> SearchLocation? in
                guard let name = item.name, let location = item.placemark.location else {
                    return nil
                }

                // restrict to only airports or towns
                guard (item.placemark.locality != nil && item.placemark.thoroughfare == nil) ||
                        (item.pointOfInterestCategory == .airport) else {
                    return nil
                }

                var region = ""
                if let administrativeArea = item.placemark.administrativeArea {
                    region = administrativeArea
                }
                if let country = item.placemark.country {
                    region = region.isEmpty ? country : "\(region), \(country)"
                }

                return .init(
                    name: name,
                    region: region,
                    coordinate: location.coordinate
                )
            }
            return .success(results)
        } catch {
            // TODO: log this
            print("[MAP] Error: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
