//
//  Weather_DVTApp.swift
//  Weather-DVT
//
//  Created by Sylvan  on 23/08/2025.
//

import SwiftUI

@main
struct WeatherDVTApp: App {
    private let container = SwiftDataManager.sharedContainer

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
                .modelContainer(container)
        }
    }
}
