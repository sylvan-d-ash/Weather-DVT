//
//  WeatherView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import SwiftUI

struct CurrentWeatherRow: View {
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

struct ForecastRow: View {
    let day: String
    let icon: String
    let temp: String

    var body: some View {
        HStack {
            Text(day)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(icon)
                .resizable()
                .frame(width: 25, alignment: .center)

            Text(temp)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

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
                } else if let forecast = viewModel.forecast {
                    Group {
                        ForEach(forecast.list) { weather in
                            ForecastRow(
                                day: weather.date.formatted(Date.FormatStyle().weekday()),
                                icon: weather.condition.icon,
                                temp: viewModel.formatTemperature(weather.currentTemperature)
                            )
                        }
                    }
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                } else {
                    EmptyView()
                }

                Spacer()
            }
            .background(.sunny)
        }
        .task {
//            await viewModel.loadWeather()
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
                CurrentWeatherRow(
                    temp: viewModel.formatTemperature(viewModel.weather?.minTemperature),
                    text: "min"
                )

                Spacer()

                CurrentWeatherRow(
                    temp: viewModel.formatTemperature(viewModel.weather?.currentTemperature),
                    text: "Current"
                )

                Spacer()

                CurrentWeatherRow(
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
