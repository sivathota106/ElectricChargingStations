import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isRequestingPermission = false
    
    private let manager = CLLocationManager()
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocationPermission() async -> Bool {
        await MainActor.run {
            isRequestingPermission = true
        }
        
        // Check current status
        let currentStatus = manager.authorizationStatus
        
        switch currentStatus {
        case .notDetermined:
            // Request permission and wait for response
            return await withCheckedContinuation { continuation in
                // Store continuation to be called when authorization changes
                self.permissionContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            await MainActor.run {
                isRequestingPermission = false
            }
            return true
        case .denied, .restricted:
            await MainActor.run {
                isRequestingPermission = false
            }
            return false
        @unknown default:
            await MainActor.run {
                isRequestingPermission = false
            }
            return false
        }
    }
    
    func requestLocation() async throws -> CLLocation {
        // First ensure we have permission
        let hasPermission = await requestLocationPermission()
        
        guard hasPermission else {
            throw LocationError.permissionDenied
        }
        
        // Request location and wait for result
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            self.location = location
        }
        
        // Complete location request if waiting
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        
        // Complete location request with error if waiting
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            isRequestingPermission = false
        }
        
        // Complete permission request if waiting
        if let continuation = permissionContinuation {
            permissionContinuation = nil
            let granted = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
            continuation.resume(returning: granted)
        }
        
        // Request location if permission was granted
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            Task {
                try? await requestLocation()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
}

// MARK: - Error Types

enum LocationError: Error, LocalizedError {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission is required to find nearby charging stations."
        }
    }
} 