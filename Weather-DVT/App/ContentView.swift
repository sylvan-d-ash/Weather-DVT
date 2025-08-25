//
//  ContentView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 23/08/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showLocations = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            WeatherView(
                .init(locationManager: DefaultLocationManager())
            )

            BottomBarView(
                showLocations: $showLocations,
                showSettings: $showSettings
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showLocations) {
            LocationsView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
