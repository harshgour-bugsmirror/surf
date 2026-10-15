import Foundation
import CoreLocation
import Combine

/// Dedicated manager to detect simulated or spoofed locations (e.g., via 3uTools or Xcode)
final class LocationSpoofDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationSpoofDetector()
    
    @Published var isLocationSpoofed: Bool = false
    @Published var spoofReason: String = ""
    
    private let locationManager = CLLocationManager()
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startMonitoring() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Direct API Check: iOS 15+ CoreLocation sourceInformation flags
        if #available(iOS 15.0, *) {
            if let sourceInfo = location.sourceInformation {
                // 1. Check if location was injected via software simulation (Xcode / 3uTools / Developer Mode)
                if sourceInfo.isSimulatedBySoftware {
                    flagSpoofedLocation(reason: "Software simulated location detected.")
                    return
                }
                
                // 2. Check if location came from an external hardware accessory (MFi dongles / spoofing hardware)
                if sourceInfo.isProducedByAccessory {
                    flagSpoofedLocation(reason: "External accessory location source detected.")
                    return
                }
            }
        }
    }
    
    private func flagSpoofedLocation(reason: String) {
        DispatchQueue.main.async {
            self.spoofReason = reason
            self.isLocationSpoofed = true
        }
    }
    
    func dismissAlert() {
        isLocationSpoofed = false
    }
}

