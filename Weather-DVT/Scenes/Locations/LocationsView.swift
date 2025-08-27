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
        NavigationStack(path: $viewModel.path) {
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
                prompt: "Search for an airport or area"
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
                            viewModel.navigateToSearchResults(for: result)
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
            .navigationDestination(for: SearchLocation.self) { searchResult in
                AddLocationView(result: searchResult) { result in
                    viewModel.addLocation(result)
                }
            }
        }
    }
}

#Preview {
    LocationsView()
}
