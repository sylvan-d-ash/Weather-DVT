//
//  Locations-ViewModel.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

extension LocationsView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var searchText = ""
        @Published private(set) var searchResults: [SearchLocation] = []
        @Published private(set) var errorMessage: String?
        @Published var path = NavigationPath()

        private let mapService: MapSearchService
        private let modelContext: ModelContextProtocol
        private var cancellables = Set<AnyCancellable>()

        init(mapService: MapSearchService = DefaultMapSearchService(), modelContext: ModelContextProtocol) {
            self.mapService = mapService
            self.modelContext = modelContext
            bindSearchText()
        }

        func navigateToSearchResults(for result: SearchLocation) {
            path.append(result)
        }

        func addLocation(_ result: SearchLocation) {
            errorMessage = nil

            // check for duplicates
            let name = result.name
            let descriptor = FetchDescriptor<CachedLocation>(predicate: #Predicate { $0.name == name })

            do {
                let count = try modelContext.fetchCount(descriptor)
                if count == 0 {
                    let location = CachedLocation(
                        name: result.name,
                        region: result.region,
                        latitude: result.coordinate.latitude,
                        longitude: result.coordinate.longitude
                    )
                    modelContext.insert(location)
                    try modelContext.save()
                }

                searchText = ""
                popToRoot()
            } catch {
                print("Failed to add location: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }

        func deleteLocations(at offsets: IndexSet, from savedLocations: [CachedLocation]) {
            for index in offsets {
                let location = savedLocations[index]
                modelContext.delete(location)
            }

            errorMessage = nil

            do {
                try modelContext.save()
            } catch {
                print("Failed to delete location(s): \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }

        private func bindSearchText() {
            $searchText
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] query in
                    Task { await self?.search(for: query) }
                }
                .store(in: &cancellables)
        }

        private func search(for query: String) async {
            errorMessage = nil

            if query.isEmpty {
                searchResults = []
                return
            }

            let response = await mapService.search(for: query)
            switch response {
            case .success(let results):
                searchResults = results
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }

        private func popToRoot() {
            guard !path.isEmpty else { return }
            path.removeLast()
        }
    }
}
