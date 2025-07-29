import SwiftUI
import MapKit

struct ChargingStationsMapView: View {
    @Binding var region: MKCoordinateRegion
    let stations: [ChargingStation]
    
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
    }
}

#Preview {
    ChargingStationsMapView(
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )),
        stations: createMockStations()
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
                "Latitude": 37.7749,
                "Longitude": -122.4194
            },
            "Distance": 0.5
        },
        {
            "ID": 2,
            "AddressInfo": {
                "Title": "Test Station 2",
                "AddressLine1": "456 Oak Ave",
                "Latitude": 37.7849,
                "Longitude": -122.4094
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
