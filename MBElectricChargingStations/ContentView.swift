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
                            mapView
                                .frame(height: 250)
                                .cornerRadius(12)
                                .padding([.top, .horizontal])
                            stationListView
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
    
    private var mapView: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.stations) { station in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)) {
                VStack {
                    Image(systemName: "bolt.car")
                        .foregroundColor(.green)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                    Text(station.title)
                        .font(.caption2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 80)
                }
            }
        }
    }
    
    private var stationListView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading stations...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        if let location = locationManager.location {
                            viewModel.fetchStations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        }
                    }
                }
            } else {
                List(viewModel.stations) { station in
                    NavigationLink(destination: StationDetailView(station: station)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "bolt.car")
                                    .foregroundColor(.green)
                                Text(station.title)
                                    .font(.headline)
                                Spacer()
                                if let distance = station.distance {
                                    Text(String(format: "%.1f km", distance))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text(station.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
