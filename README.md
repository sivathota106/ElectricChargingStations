# EV Charging Stations iOS App

This iOS application displays nearby electric vehicle (EV) charging stations using the [OpenChargeMap API](https://openchargemap.org/site/develop/api). The app is built with SwiftUI and follows the MVVM (Model-View-ViewModel) architecture for modularity and testability.

## Features
- **Location Access:** Requests and uses the user's current location to find nearby charging stations.
- **Map View:** Displays charging stations as pins on a map.
- **List View:** Shows a list of nearby stations with basic details.
- **Station Details:** Tap a station to view more information.
- **Error Handling:** Alerts for location or network errors.

## Architecture
- **MVVM Pattern:**
  - **Model:** Data structures for charging stations and addresses, matching the OpenChargeMap API response.
  - **ViewModel:** Handles business logic, data fetching, and state management. Exposes observable properties for the view.
  - **View:** SwiftUI views for map, list, and details, reacting to ViewModel state.
- **Networking:**
  - `OpenChargeMapService` fetches station data from the API using `URLSession`.
- **Location:**
  - `LocationManager` handles CoreLocation permissions and provides the user's current coordinates.

## Folder Structure
```
MBElectricChargingStations
├── Model/
│   └── ChargingStation.swift
├── Services/
│   └── OpenChargeMapService.swift
│   └── LocationManager.swift
├── ViewModel/
│   └── ChargingStationsViewModel.swift
├── View/
│   ├── ChargingStationsMapView.swift
│   ├── ChargingStationsListView.swift
│   └── StationDetailView.swift
├── ContentView.swift
├── MBElectricChargingStationsApp.swift
```

## Setup Instructions
1. **Clone the repository and open in Xcode.**
2. **Add Location Usage Description:**
   - Open `Info.plist` and add:
     - Key: `NSLocationWhenInUseUsageDescription`
     - Value: `This app needs your location to show nearby EV charging stations.`
3. **Build and run** on a simulator or device with location services enabled.

## OpenChargeMap API
- The app uses the public OpenChargeMap API to fetch charging station data based on the user's location.
- No API key is required for basic usage, but you can add your own for higher rate limits.

## Customization & Testing
- The app is modular and testable. You can add unit tests for the ViewModel and networking layers.
- UI can be customized further for branding or additional features.

---

## Unit Tests

Unit tests are provided for the `ChargingStationsViewModel` in `MBRDNAEVTests/ChargingStationsViewModelTests.swift`.

### What is tested?
- **Success:** Verifies that stations are loaded correctly from the mock service.
- **Failure:** Verifies that errors are handled and reported.
- **Empty:** Verifies that an empty result is handled gracefully.

### How to run the tests
1. Open the project in Xcode.
2. Select the `MBRDNAEVTests` scheme.
3. Press `⌘U` or go to **Product > Test**.

---

## Troubleshooting: Location Error (kCLErrorDomain Code=1)

If you see this error in the debug console:

```
Location error: Error Domain=kCLErrorDomain Code=1 "(null)"
```

This means **location access was denied** to the app.

### What does it mean?
- **Code 1** in `kCLErrorDomain` is `kCLErrorDenied`.
- The user (or simulator/device) denied location permissions to your app.

### How to Fix

#### 1. Check Info.plist
Make sure you have this in your `Info.plist`:
- **Key:** `NSLocationWhenInUseUsageDescription`
- **Value:** `This app needs your location to show nearby EV charging stations.`

#### 2. Reset Location Permissions in Simulator
- Open the iOS Simulator.
- Go to **Features > Location** and select a location (e.g., "Apple", "City Bicycle Ride", or "Custom Location").
- If you previously denied location, delete the app from the simulator and reinstall it, or reset permissions:
  - In Simulator: **Device > Erase All Content and Settings...**
  - Or, in the app, go to Settings > Privacy > Location Services and allow location for your app.

#### 3. On a Real Device
- Go to **Settings > Privacy & Security > Location Services**.
- Find your app and set it to "While Using the App" or "Always".

#### 4. Clean and Rebuild
- Sometimes, cleaning the build folder and restarting the simulator helps:
  - Product > Clean Build Folder (⇧⌘K)
  - Product > Build (⌘B)

| Error Code | Meaning         | Solution                                      |
|------------|----------------|-----------------------------------------------|
| 1          | Denied         | Allow location in settings/simulator, check Info.plist |

---

**Author:** Siva Thota 
