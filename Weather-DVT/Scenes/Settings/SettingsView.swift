//
//  SettingsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

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

struct SettingsView: View {
    @AppStorage("theme")
    var selectedTheme: Theme = .forest

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Theme")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(Theme.allCases) { theme in
                    themeButton(for: theme)
                }
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }

    @ViewBuilder
    private func themeButton(for theme: Theme) -> some View {
        let isSelected = theme.id == selectedTheme.id

        Button {
            selectedTheme = theme
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                    Text(theme.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()
                }

                Image(theme.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2, x: 0, y: 1)
            }
            .foregroundStyle(.primary)
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : .secondary.opacity(0.3), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: isSelected)
    }
}

#Preview {
    SettingsView()
}
