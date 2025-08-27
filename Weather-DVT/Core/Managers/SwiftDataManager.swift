//
//  SwiftDataManager.swift
//  Weather-DVT
//
//  Created by Sylvan  on 27/08/2025.
//

import Foundation
import SwiftData

enum SwiftDataManager {
    private static let schema = Schema([
        CachedLocation.self,
        CachedCurrentWeather.self,
        CachedForecastWeather.self,
    ])

    static let sharedContainer: ModelContainer = configureModelContainer()

    static func configureModelContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration()
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    static func previewContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }
}
