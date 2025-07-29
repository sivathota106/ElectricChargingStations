import SwiftUI

struct ChargingStationsListView: View {
    @ObservedObject var viewModel: ChargingStationsViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading stations...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        // This will be handled by the parent view
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

#Preview {
    NavigationView {
        ChargingStationsListView(viewModel: ChargingStationsViewModel())
    }
} 