//
//  SearchLocation.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import CoreLocation
import Foundation

struct SearchLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let region: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: SearchLocation, rhs: SearchLocation) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
