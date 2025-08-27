//
//  WeatherView.swift
//  Weather-DVT
//
//  Created by Sylvan  on 24/08/2025.
//

import Combine
import CoreLocation
import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel: ViewModel

    init(_ viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: -2) {
                headerView

                VStack(spacing: 24) {
                    currentWeather
                    forecastContent
                    Spacer()
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(viewModel.backgroundColor)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.requestAuthorization()
        }
    }

    private var headerView: some View {
        ZStack {
            Image(viewModel.backgroundImage)
                .resizable()
                .frame(maxWidth: .infinity)

            VStack(spacing: 24) {
                Spacer()

                Text(viewModel.formatTemperature(viewModel.weather?.currentTempInCelcius))

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
                    temp: viewModel.formatTemperature(viewModel.weather?.minTempInCelcius),
                    text: "min"
                )

                Spacer()

                CurrentWeatherColumn(
                    temp: viewModel.formatTemperature(viewModel.weather?.currentTempInCelcius),
                    text: "Current"
                )

                Spacer()

                CurrentWeatherColumn(
                    temp: viewModel.formatTemperature(viewModel.weather?.maxTempInCelcius),
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

    private var forecastContent: some View {
        Group {
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
                            temp: viewModel.formatTemperature(weather.currentTempInCelcius)
                        )
                    }
                }
                .font(.title)
                .foregroundStyle(.white)
                .padding(.horizontal)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.white)
                    .clipShape(.capsule)
            }
        }
    }
}

private final class MockLocationManager: UserLocationManager {
    private let locationSubject = PassthroughSubject<CLLocationCoordinate2D?, Never>()
    private let authSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let errorSubject = PassthroughSubject<String?, Never>()

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authSubject.eraseToAnyPublisher()
    }

    var errorMessagePublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    func requestAuthorization() {
        // Simulate granted auth
        authSubject.send(.authorizedWhenInUse)
    }

    func requestLocation() {
        // Simulate fake location
        locationSubject.send(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    }
}

#Preview {
    WeatherView(
        .init(
            locationManager: MockLocationManager(),
            persistenceService: DefaultPersistenceService(
                modelContext: SwiftDataManager.previewContainer().mainContext
            )
        )
    )
}
