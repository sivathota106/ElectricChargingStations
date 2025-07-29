import Foundation
import Combine

class ChargingStationsViewModel: ObservableObject {
    @Published private(set) var stations: [ChargingStation] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private let service: OpenChargeMapService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: OpenChargeMapService = OpenChargeMapService()) {
        self.service = service
    }
    
    func fetchStations(latitude: Double, longitude: Double) {
        isLoading = true
        errorMessage = nil
        service.fetchStations(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stations):
                    self?.stations = stations
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 