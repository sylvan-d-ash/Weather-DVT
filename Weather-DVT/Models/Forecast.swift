//
//  Forecast.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Foundation

struct Forecast: Identifiable {
    let id = UUID()
    let date: Date
    let city: String
    let list: [Weather]
}
