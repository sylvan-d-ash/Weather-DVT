//
//  WeatherView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: -2) {
            headerView

            VStack(spacing: 24) {
                currentWeather

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else if !viewModel.dailySummaries.isEmpty {
                    Group {
                        ForEach(viewModel.dailySummaries) { weather in
                            DailyForecastRow(
                                day: weather.date,
                                icon: weather.condition.icon,
                                temp: viewModel.formatTemperature(weather.currentTemperature)
                            )
                        }
                    }
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                }

                Spacer()
            }
            .background(.sunny)
        }
        .task {
            await viewModel.loadWeather()
        }
    }

    private var headerView: some View {
        ZStack {
            Image(viewModel.backgroundImage)
                .resizable()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 24) {
                Spacer()

                Text(viewModel.formatTemperature(viewModel.weather?.currentTemperature))

                Text(viewModel.weather?.condition.text ?? "--")

                Spacer()
            }
            .font(.system(size: 44, weight: .bold, design: .default))
            .foregroundStyle(.white)
        }
    }

    private var currentWeather: some View {
        VStack {
            HStack {
                CurrentWeatherColumn(
                    temp: viewModel.formatTemperature(viewModel.weather?.minTemperature),
                    text: "min"
                )

                Spacer()

                CurrentWeatherColumn(
                    temp: viewModel.formatTemperature(viewModel.weather?.currentTemperature),
                    text: "Current"
                )

                Spacer()

                CurrentWeatherColumn(
                    temp: viewModel.formatTemperature(viewModel.weather?.maxTemperature),
                    text: "max"
                )
            }
            .padding(.horizontal)

            Divider()
                .frame(height: 2)
                .background(.white)
        }
        .padding(.top)
    }
}

#Preview {
    WeatherView()
}
