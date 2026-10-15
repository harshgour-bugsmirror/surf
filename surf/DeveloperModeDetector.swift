import Foundation
import Combine

/// Minimal detector for iOS Developer Mode via AMFI sysctl
final class DeveloperModeDetector: ObservableObject {
    static let shared = DeveloperModeDetector()
    
    @Published var isDeveloperModeEnabled: Bool = false
    @Published var developerModeReason: String = ""
    
    private init() {}
    
    func checkDeveloperStatus() {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        
        // Returns 0 on success, and value != 0 if Developer Mode is ON
        if sysctlbyname("security.mac.amfi.developer_mode_status", &value, &size, nil, 0) == 0, value != 0 {
            DispatchQueue.main.async {
                self.developerModeReason = "iOS Developer Mode is turned ON in system Settings."
                self.isDeveloperModeEnabled = true
            }
        }
    }
    
    func dismissAlert() {
        isDeveloperModeEnabled = false
    }
}
    