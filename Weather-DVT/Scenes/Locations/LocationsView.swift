//
//  LocationsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftData
import SwiftUI

struct LocationsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ViewModel

    @Query(sort: \CachedLocation.date)
    private var savedLocations: [CachedLocation]

    let didSelectLocation: (CachedLocation) -> Void

    init(_ viewModel: ViewModel, didSelectLocation: @escaping (CachedLocation) -> Void) {
        _viewModel = .init(wrappedValue: viewModel)
        self.didSelectLocation = didSelectLocation
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                ForEach(savedLocations, id: \.self) { location in
                    Button {
                        didSelectLocation(location)
                    } label: {
                        Text(location.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    viewModel.deleteLocations(at: offsets, from: savedLocations)
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
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }

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
    LocationsView(
        .init(modelContext: SwiftDataManager.previewContainer().mainContext)
    ) { location in
        print(location.name)
    }
    .modelContainer(SwiftDataManager.previewContainer())
}
