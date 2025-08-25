//
//  LocationManager.swift
//  Weather-DVT
//
//  Created by Sylvan  on 25/08/2025.
//

import Combine
import CoreLocation
import Foundation

protocol LocationManager: AnyObject {
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> { get }
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }

    func requestLocation()
}

final class DefaultLocationManager: NSObject, ObservableObject, LocationManager {
    @Published private var location: CLLocationCoordinate2D?
    @Published private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private var errorMessage: String?

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
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

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension DefaultLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
