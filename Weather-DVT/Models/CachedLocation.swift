//
//  CachedLocation.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

@Model
final class CachedLocation {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var region: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var isCurrentUserLocation: Bool = false

    @Relationship(deleteRule: .cascade)
    var weather: CachedWeather?

    init(
        id: UUID = UUID(),
        name: String,
        region: String,
        latitude: Double,
        longitude: Double,
        isCurrentUserLocation: Bool = false
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
        self.date = .now
        self.isCurrentUserLocation = isCurrentUserLocation
    }
}
