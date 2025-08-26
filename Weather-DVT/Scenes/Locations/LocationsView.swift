//
//  LocationsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct LocationsView: View {
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
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a city or airport"
            )
        }
    }
}

#Preview {
    LocationsView()
}
