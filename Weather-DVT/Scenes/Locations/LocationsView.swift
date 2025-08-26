//
//  LocationsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct LocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.savedLocations, id: \.self) { location in
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
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a city or town"
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { result in
                        Button {
                            print(result.name)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.name)
                                Text(result.region)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            // Make the entire row tappable
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(.thinMaterial)
                }
            }
        }
    }
}

#Preview {
    LocationsView()
}
