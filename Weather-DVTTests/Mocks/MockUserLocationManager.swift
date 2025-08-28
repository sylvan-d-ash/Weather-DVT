//
//  MockUserLocationManager.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Combine
import CoreLocation
import Foundation
@testable import Weather_DVT

final class MockUserLocationManager: UserLocationManager {
    private(set) var didCallRequestAuthorization = false
    private(set) var didCallRequestLocation = false

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
        didCallRequestAuthorization = true
    }

    func requestLocation() {
        didCallRequestLocation = true
    }

    func simulateLocationUpdate(coordinate: CLLocationCoordinate2D) {
        locationSubject.send(coordinate)
    }

    func simulateAuthorizationChange(status: CLAuthorizationStatus) {
        authSubject.send(status)
    }

    func simulateError(message: String) {
        errorSubject.send(message)
    }
}
