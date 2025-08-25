//
//  ContentView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 23/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WeatherView(
            .init(locationManager: DefaultLocationManager())
        )
    }
}

#Preview {
    ContentView()
}
