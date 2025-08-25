//
//  SettingsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct SettingsView: View {
    enum Theme:String, Identifiable, CaseIterable {
        case forest
        case sea

        var id: String { self.rawValue }

        var displayName: String {
            switch self {
            case .forest: return "Forest"
            case .sea: return "Sea"
            }
        }

        var image: String {
            switch self {
            case .forest: return "forest_sunny"
            case .sea: return "sea_sunny"
            }
        }
    }

    @State var selectedTheme: Theme = .forest

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
                HStack(spacing: 16) {
                    Image(systemName: isSelected ? "checkmark.circle" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.blue : .gray.opacity(0.5))
                    
                    Text(theme.displayName)
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }

                Image(theme.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
            }
            .foregroundStyle(.black)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : .gray.opacity(0.3), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: isSelected)
    }
}

#Preview {
    SettingsView()
}
