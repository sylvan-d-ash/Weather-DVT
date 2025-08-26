//
//  LocationSearchResult.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import CoreLocation
import Foundation

struct LocationSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let coordinate: CLLocationCoordinate2D
}
