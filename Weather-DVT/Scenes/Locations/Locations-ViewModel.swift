//
//  Locations-ViewModel.swift
//  Weather-DVT
//
//  Created by Sylvan  on 26/08/2025.
//

import Combine
import Foundation
import SwiftUI

extension LocationsView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var searchText = ""
        @Published private(set) var savedLocations = ["Nairobi", "Cape Town", "New York"]
        @Published private(set) var searchResults: [SearchLocation] = []
        @Published private(set) var errorMessage: String?
        @Published var path = NavigationPath()

        private let mapService: MapSearchService
        private var cancellables = Set<AnyCancellable>()

        init(mapService: MapSearchService = DefaultMapSearchService()) {
            self.mapService = mapService
            bindSearchText()
        }

        func navigateToSearchResults(for result: SearchLocation) {
            path.append(result)
        }

        func addLocation(_ result: SearchLocation) {
            print(result)
            popToRoot()
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
            path.removeLast()
        }
    }
}
