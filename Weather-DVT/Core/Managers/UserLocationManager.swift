//
//  UserLocationManager.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Combine
import CoreLocation
import Foundation

protocol UserLocationManager: AnyObject {
    var locationPublisher: AnyPublisher<CLLocation?, Never> { get }
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }

    func requestAuthorization()
    func requestLocation()
}

final class DefaultUserLocationManager: NSObject, ObservableObject, UserLocationManager {
    @Published private var location: CLLocation?
    @Published private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private var errorMessage: String?

    var locationPublisher: AnyPublisher<CLLocation?, Never> {
        $location.eraseToAnyPublisher()
    }

    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        $authorizationStatus.eraseToAnyPublisher()
    }

    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    private let manager: CLLocationManager

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }
}

extension DefaultUserLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
