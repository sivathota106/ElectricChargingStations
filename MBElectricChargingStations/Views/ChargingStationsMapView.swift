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
        stations: [
            ChargingStation(
                id: 1,
                title: "Test Station 1",
                address: "123 Main St",
                latitude: 37.7749,
                longitude: -122.4194,
                distance: 0.5
            ),
            ChargingStation(
                id: 2,
                title: "Test Station 2",
                address: "456 Oak Ave",
                latitude: 37.7849,
                longitude: -122.4094,
                distance: 1.2
            )
        ]
    )
} 