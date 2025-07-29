//
//  ContentView.swift
//  MBElectricChargingStations
//
//  Created by Siva Thota on 7/27/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ChargingStationsViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var hasFetchedForLocation = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var locationError: String?
    
    var body: some View {
        NavigationView {
            Group {
                switch locationManager.authorizationStatus {
                case .notDetermined:
                    VStack(spacing: 20) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Location Access Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("We need your location to show nearby charging stations.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await requestLocationPermission()
                            }
                        }) {
                            HStack {
                                if locationManager.isRequestingPermission {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "location.fill")
                                }
                                Text(locationManager.isRequestingPermission ? "Requesting..." : "Allow Location Access")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(locationManager.isRequestingPermission)
                    }
                    .padding()
                    
                case .restricted, .denied:
                    VStack(spacing: 20) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Location Access Denied")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Please enable location access in Settings to find nearby charging stations.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Open Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    
                case .authorizedWhenInUse, .authorizedAlways:
                    if let location = locationManager.location {
                        VStack {
                            ChargingStationsMapView(
                                region: $region,
                                stations: viewModel.stations,
                                userLocation: location
                            )
                            ChargingStationsListView(viewModel: viewModel)
                        }
                        .onAppear {
                            if !hasFetchedForLocation {
                                viewModel.fetchStations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                hasFetchedForLocation = true
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Getting your location...")
                                .font(.headline)
                            
                            if let error = locationError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                
                                Button("Retry") {
                                    Task {
                                        await requestLocationPermission()
                                    }
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .onAppear {
                            Task {
                                await requestLocationPermission()
                            }
                        }
                    }
                    
                default:
                    ProgressView("Checking location permissions...")
                }
            }
            .navigationTitle("EV Charging Stations")
        }
        .onChange(of: locationManager.location) { newLocation in
            hasFetchedForLocation = false
            locationError = nil
            if let loc = newLocation {
                region.center = loc.coordinate
            }
        }
    }
    
    private func requestLocationPermission() async {
        do {
            _ = try await locationManager.requestLocation()
        } catch {
            await MainActor.run {
                locationError = error.localizedDescription
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
