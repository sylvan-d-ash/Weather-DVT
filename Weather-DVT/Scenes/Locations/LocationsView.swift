//
//  LocationsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct LocationsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    private let locations = ["Nairobi", "Cape Town", "New York"]

    var body: some View {
        NavigationStack {
            List {
                ForEach(locations, id: \.self) { location in
                    Button {
                        print("Location: \(location)")
                    } label: {
                        Text(location)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Locations")
            .scrollContentBackground(.hidden)
            .background(.regularMaterial)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a city or airport"
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LocationsView()
}
