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
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        NavigationView {
            Group {
                switch locationManager.authorizationStatus {
                case .notDetermined:
                    VStack {
                        Text("We need your location to show nearby charging stations.")
                        Button("Allow Location Access") {
                            locationManager.requestLocation()
                        }
                    }
                case .restricted, .denied:
                    VStack {
                        Text("Location access denied. Please enable it in Settings.")
                            .foregroundColor(.red)
                        Button("Retry") {
                            locationManager.requestLocation()
                        }
                    }
                case .authorizedWhenInUse, .authorizedAlways:
                    if let location = locationManager.location {
                        VStack {
                            ChargingStationsMapView(region: $region, stations: viewModel.stations)
                            ChargingStationsListView(viewModel: viewModel)
                        }
                        .onAppear {
                            if !hasFetchedForLocation {
                                viewModel.fetchStations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                region.center = location.coordinate
                                hasFetchedForLocation = true
                            }
                        }
                    } else {
                        ProgressView("Getting your location...")
                            .onAppear {
                                locationManager.requestLocation()
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
            if let loc = newLocation {
                region.center = loc.coordinate
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
