//
//  DailyForecastRow.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct DailyForecastRow: View {
    let day: Date
    let icon: String
    let temp: String

    var body: some View {
        HStack {
            Text(day.formatted(Date.FormatStyle().weekday(.wide)))
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25, alignment: .center)

            Text(temp)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
