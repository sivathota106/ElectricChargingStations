import SwiftUI
import MapKit

struct StationDetailView: View {
    let station: ChargingStation
    @State private var region: MKCoordinateRegion
    
    init(station: ChargingStation) {
        self.station = station
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with station icon
                HStack {
                    Image(systemName: "bolt.car.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text(station.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        if let distance = station.distance {
                            Text(String(format: "%.1f km away", distance))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Map showing station location
                Map(coordinateRegion: $region, annotationItems: [station]) { station in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)) {
                        VStack {
                            Image(systemName: "bolt.car")
                                .foregroundColor(.green)
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                // Station details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "location.fill", title: "Address", value: station.address)
                    DetailRow(icon: "mappin.and.ellipse", title: "Coordinates", value: String(format: "%.6f, %.6f", station.latitude, station.longitude))
                    DetailRow(icon: "number", title: "Station ID", value: "\(station.id)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        openInMaps()
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Open in Maps")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        shareStation()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Station Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = station.title
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func shareStation() {
        let text = "\(station.title)\n\(station.address)\nCoordinates: \(station.latitude), \(station.longitude)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        StationDetailView(station: createMockStation())
    }
}

// Helper function to create a mock station for preview
private func createMockStation() -> ChargingStation {
    // Create a mock JSON that matches the API structure
    let mockJSON = """
    {
        "ID": 12345,
        "AddressInfo": {
            "Title": "Test Charging Station",
            "AddressLine1": "123 Main Street, San Francisco, CA",
            "Latitude": 37.7749,
            "Longitude": -122.4194
        },
        "Distance": 0.5
    }
    """.data(using: .utf8)!
    
    do {
        return try JSONDecoder().decode(ChargingStation.self, from: mockJSON)
    } catch {
        // Fallback to a basic station if decoding fails
        fatalError("Failed to create mock station: \(error)")
    }
} 
