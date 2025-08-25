//
//  BottomBarView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var showLocations: Bool
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            Spacer()

            Button {
                showLocations = true
            } label: {
                VStack {
                    Image(systemName: "location")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Locations")
                        .font(.caption2)
                }
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Settings")
                        .font(.caption2)
                }
            }

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
}
