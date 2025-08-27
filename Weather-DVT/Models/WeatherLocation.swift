//
//  WeatherLocation.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import CoreLocation

struct WeatherLocation: Identifiable, Hashable {
    enum Kind: Hashable {
        case current
        case temporary
        case saved(persistenceModelID: UUID)
    }

    let id: String
    let name: String
    let region: String
    let latitude: Double
    let longitude: Double
    let kind: Kind
}

extension WeatherLocation {
    init(from clLocation: CLLocationCoordinate2D) {
        id = "current"
        name = "" // TODO: use reverse geocoder
        region = ""
        latitude = clLocation.latitude
        longitude = clLocation.longitude
        kind = .current
    }

    init(from searchLocation: SearchLocation) {
        id = searchLocation.id.uuidString
        name = searchLocation.name
        region = searchLocation.region
        latitude = searchLocation.coordinate.latitude
        longitude = searchLocation.coordinate.longitude
        kind = .temporary
    }

    init(from cachedLocation: CachedLocation) {
        id = cachedLocation.id.uuidString
        name = cachedLocation.name
        region = cachedLocation.region
        latitude = cachedLocation.latitude
        longitude = cachedLocation.longitude
        kind = .saved(persistenceModelID: cachedLocation.id)
    }
}
