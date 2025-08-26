//
//  AddLocationView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import SwiftUI

struct AddLocationView: View {
    let result: LocationSearchResult
    let onAddLocation: (LocationSearchResult) -> ()

    var body: some View {
        WeatherView(
            .init(locationManager: DefaultLocationManager())
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onAddLocation(result)
                }
                .foregroundStyle(.white)
                .padding(.horizontal)
                .background(.blue)
                .clipShape(.capsule)
            }
        }
        .tint(.white)
    }
}

#Preview {
    let result = LocationSearchResult(name: "Thika", region: "Thika", coordinate: .init(latitude: 1, longitude: 1))
    NavigationStack {
        AddLocationView(result: result) { result in
            print(result)
        }
    }
}
