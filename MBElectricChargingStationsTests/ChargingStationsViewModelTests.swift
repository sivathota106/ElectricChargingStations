import XCTest
@testable import MBElectricChargingStations

class MockOpenChargeMapService: OpenChargeMapService {
    var shouldReturnError = false
    var mockStations: [ChargingStation] = []
    var fetchCalled = false
    
    override func fetchStations(latitude: Double, longitude: Double, distance: Double = 10, completion: @escaping (Result<[ChargingStation], Error>) -> Void) {
        fetchCalled = true
        if shouldReturnError {
            completion(.failure(NSError(domain: "Test", code: 1)))
        } else {
            completion(.success(mockStations))
        }
    }
}

class ChargingStationsViewModelTests: XCTestCase {
    var viewModel: ChargingStationsViewModel!
    var mockService: MockOpenChargeMapService!
    
    override func setUp() {
        super.setUp()
        mockService = MockOpenChargeMapService()
        viewModel = ChargingStationsViewModel(service: mockService)
    }
    
    func testFetchStationsSuccess() {
        let station = ChargingStation(id: 1, title: "Test Station", address: "123 Main St", latitude: 1.0, longitude: 2.0, distance: 0.5)
        mockService.mockStations = [station]
        let expectation = self.expectation(description: "Stations loaded")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.stations.count, 1)
            XCTAssertEqual(self.viewModel.stations.first?.title, "Test Station")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFetchStationsFailure() {
        mockService.shouldReturnError = true
        let expectation = self.expectation(description: "Error handled")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.stations.count, 0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
} 