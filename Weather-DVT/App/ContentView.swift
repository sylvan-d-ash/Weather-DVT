//
//  ContentView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 23/08/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext: ModelContext

    @StateObject private var weatherViewModel: WeatherView.ViewModel

    @State private var showLocations = false
    @State private var showSettings = false

    init(modelContext: ModelContext) {
        _weatherViewModel = .init(
            wrappedValue: .init(
                locationManager: DefaultUserLocationManager(),
                persistenceService: DefaultPersistenceService(
                    modelContext: modelContext
                )
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            WeatherView(weatherViewModel)

            BottomBarView(
                showLocations: $showLocations,
                showSettings: $showSettings
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showLocations) {
            LocationsView(.init(modelContext: modelContext)) { selectedLocation in
                weatherViewModel.updateLocation(to: selectedLocation)
                showLocations = false
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    let container = SwiftDataManager.previewContainer()
    ContentView(modelContext: container.mainContext)
        .modelContainer(container)
}
