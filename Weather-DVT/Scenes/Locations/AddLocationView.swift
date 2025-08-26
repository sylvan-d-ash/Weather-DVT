//
//  AddLocationView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import SwiftUI

struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss

    let result: LocationSearchResult
    let onAddLocation: (LocationSearchResult) -> ()

    var body: some View {
        NavigationStack {
            WeatherView(
                .init(locationManager: DefaultLocationManager())
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .background(.secondary.opacity(0.5))
                    .clipShape(.capsule)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAddLocation(result)
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .background(.blue)
                    .clipShape(.capsule)
                }
            }
        }
    }
}

#Preview {
    let result = LocationSearchResult(name: "Thika", region: "Thika", coordinate: .init(latitude: 1, longitude: 1))
    AddLocationView(result: result) { result in
        print(result)
    }
}
