//
//  MapSearchService.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import Foundation
import MapKit

// MARK: - MKPlacemark
protocol PlacemarkForMK {
    var locality: String? { get }
    var thoroughfare: String? { get }
    var administrativeArea: String? { get }
    var country: String? { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension MKPlacemark: PlacemarkForMK {}

// MARK: - MKMapItem
protocol MapItem {
    var name: String? { get }
    var localPlacemark: PlacemarkForMK { get }
    var pointOfInterestCategory: MKPointOfInterestCategory? { get }
}

extension MKMapItem: MapItem {
    var localPlacemark: any PlacemarkForMK { self.placemark }
}

// MARK: - MKLocalSearch.Response
protocol LocalSearchResponse {
    var localMapItems: [MapItem] { get }
}

extension MKLocalSearch.Response: LocalSearchResponse {
    var localMapItems: [any MapItem] { self.mapItems }
}

// MARK: - MKLocalSearch
protocol MKLocalSearchProtocol: AnyObject {
    func localStart() async throws -> LocalSearchResponse
}

extension MKLocalSearch: MKLocalSearchProtocol {
    func localStart() async throws -> any LocalSearchResponse {
        return try await start() as LocalSearchResponse
    }
}

// MARK: - MapSearchService
protocol MapSearchService: AnyObject {
    func search(for query: String) async -> Result<[SearchLocation], Error>
}

final class DefaultMapSearchService: MapSearchService {
    typealias SearchMaker = (MKLocalSearch.Request) -> MKLocalSearchProtocol

    private let searchMaker: SearchMaker

    init(searchMaker: @escaping SearchMaker = { request in MKLocalSearch(request: request) }) {
        self.searchMaker = searchMaker
    }

    func search(for query: String) async -> Result<[SearchLocation], any Error> {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        let search = searchMaker(request)

        do {
            let response = try await search.localStart()
            let results = response.localMapItems.compactMap { item -> SearchLocation? in
                guard let name = item.name else {
                    return nil
                }

                let placemark = item.localPlacemark

                // restrict to only airports or towns
                guard (placemark.locality != nil && placemark.thoroughfare == nil) ||
                        (item.pointOfInterestCategory == .airport) else {
                    return nil
                }

                var region = ""
                if let administrativeArea = placemark.administrativeArea {
                    region = administrativeArea
                }
                if let country = placemark.country {
                    region = region.isEmpty ? country : "\(region), \(country)"
                }

                return .init(
                    name: name,
                    region: region,
                    coordinate: placemark.coordinate
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
