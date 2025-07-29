import SwiftUI
import MapKit

struct ChargingStationsMapView: View {
    @Binding var region: MKCoordinateRegion
    let stations: [ChargingStation]
    let userLocation: CLLocation?
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: stations) { station in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)) {
                VStack {
                    Image(systemName: "bolt.car")
                        .foregroundColor(.green)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                    Text(station.title)
                        .font(.caption2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 80)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(4)
                }
            }
        }
        .frame(height: 250)
        .cornerRadius(12)
        .padding([.top, .horizontal])
        .onAppear {
            updateMapRegion()
        }
        .onChange(of: userLocation) { _ in
            updateMapRegion()
        }
    }
    
    private func updateMapRegion() {
        guard let userLocation = userLocation else { return }
        
        // Update the map region to center on user's location
        region.center = userLocation.coordinate
        
        // Adjust the span to show a reasonable area around the user
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        region.span = span
    }
}

#Preview {
    ChargingStationsMapView(
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )),
        stations: createMockStations(),
        userLocation: nil
    )
}

// Helper function to create mock stations for preview
private func createMockStations() -> [ChargingStation] {
    let mockJSON = """
    [
        {
            "ID": 1,
            "AddressInfo": {
                "Title": "Test Station 1",
                "AddressLine1": "123 Main St",
                "Latitude": 0.0,
                "Longitude": 0.0
            },
            "Distance": 0.5
        },
        {
            "ID": 2,
            "AddressInfo": {
                "Title": "Test Station 2",
                "AddressLine1": "456 Oak Ave",
                "Latitude": 0.001,
                "Longitude": 0.001
            },
            "Distance": 1.2
        }
    ]
    """.data(using: .utf8)!
    
    do {
        return try JSONDecoder().decode([ChargingStation].self, from: mockJSON)
    } catch {
        // Return empty array if decoding fails
        print("Failed to create mock stations: \(error)")
        return []
    }
} 
