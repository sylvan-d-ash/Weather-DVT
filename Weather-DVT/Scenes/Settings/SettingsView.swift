//
//  SettingsView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("theme")
    var selectedTheme: Theme = .forest

    @AppStorage("unit")
    var selectedUnit: TemperatureUnit = .celcius

    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    ForEach(TemperatureUnit.allCases) { unit in
                        unitButton(for: unit)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                Section("Theme") {
                    VStack(spacing: 12) {
                        ForEach(Theme.allCases) { theme in
                            themeButton(for: theme)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .background(.regularMaterial)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func unitButton(for unit: TemperatureUnit) -> some View {
        let isSelected = unit.id == selectedUnit.id

        Button {
            selectedUnit = unit
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark")
                    .opacity(isSelected ? 1 : 0)

                Text(unit.name)

                Text("(\(unit.symbol))")

                Spacer()
            }
            .padding(.horizontal)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
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
                    .frame(maxHeight: 200)
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
