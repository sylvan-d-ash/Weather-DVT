//
//  Theme.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Foundation

enum Theme: String, Identifiable, CaseIterable, Codable {
    case forest
    case sea

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .forest: return "Forest"
        case .sea: return "Sea"
        }
    }

    var base: String {
        switch self {
        case .forest: return "forest_"
        case .sea: return "sea_"
        }
    }

    var image: String { base + "sunny" }
}
