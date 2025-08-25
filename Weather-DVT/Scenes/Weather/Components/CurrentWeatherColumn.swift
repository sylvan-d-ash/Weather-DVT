//
//  CurrentWeatherColumn.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct CurrentWeatherColumn: View {
    let temp: String
    let text: String

    var body: some View {
        VStack {
            Text(temp)
                .fontWeight(.bold)
                .font(.title2)

            Text(text)
                .font(.title3)
        }
        .foregroundStyle(.white)
    }
}
