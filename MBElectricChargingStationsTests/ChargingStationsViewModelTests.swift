import XCTest
@testable import MBElectricChargingStations

class MockOpenChargeMapService: OpenChargeMapService {
    var shouldReturnError = false
    var mockStations: [ChargingStation] = []
    var fetchCalled = false
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastDistance: Double?
    
    override func fetchStations(latitude: Double, longitude: Double, distance: Double = 10, completion: @escaping (Result<[ChargingStation], Error>) -> Void) {
        fetchCalled = true
        lastLatitude = latitude
        lastLongitude = longitude
        lastDistance = distance
        
        if shouldReturnError {
            completion(.failure(NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])))
        } else {
            completion(.success(mockStations))
        }
    }
    
    func reset() {
        shouldReturnError = false
        mockStations = []
        fetchCalled = false
        lastLatitude = nil
        lastLongitude = nil
        lastDistance = nil
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
    
    override func tearDown() {
        mockService.reset()
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testFetchStationsSuccess() {
        // Given
        let mockStation = createMockStation(id: 1, title: "Test Station", address: "123 Main St", latitude: 1.0, longitude: 2.0, distance: 0.5)
        mockService.mockStations = [mockStation]
        
        // When
        let expectation = self.expectation(description: "Stations loaded successfully")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after successful fetch")
            XCTAssertNil(self.viewModel.errorMessage, "Error message should be nil after successful fetch")
            XCTAssertEqual(self.viewModel.stations.count, 1, "Should have exactly one station")
            XCTAssertEqual(self.viewModel.stations.first?.title, "Test Station", "Station title should match")
            XCTAssertEqual(self.viewModel.stations.first?.address, "123 Main St", "Station address should match")
            XCTAssertEqual(self.viewModel.stations.first?.distance, 0.5, "Station distance should match")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFetchStationsWithMultipleStations() {
        // Given
        let station1 = createMockStation(id: 1, title: "Station 1", address: "Address 1", latitude: 1.0, longitude: 2.0, distance: 0.5)
        let station2 = createMockStation(id: 2, title: "Station 2", address: "Address 2", latitude: 1.1, longitude: 2.1, distance: 1.0)
        mockService.mockStations = [station1, station2]
        
        // When
        let expectation = self.expectation(description: "Multiple stations loaded")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.stations.count, 2, "Should have exactly two stations")
            XCTAssertEqual(self.viewModel.stations.first?.title, "Station 1", "First station title should match")
            XCTAssertEqual(self.viewModel.stations.last?.title, "Station 2", "Second station title should match")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Failure Tests
    
    func testFetchStationsFailure() {
        // Given
        mockService.shouldReturnError = true
        
        // When
        let expectation = self.expectation(description: "Error handled properly")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after error")
            XCTAssertNotNil(self.viewModel.errorMessage, "Error message should not be nil after error")
            XCTAssertEqual(self.viewModel.stations.count, 0, "Should have no stations after error")
            XCTAssertTrue(self.viewModel.errorMessage?.contains("Mock network error") == true, "Error message should contain the mock error")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFetchStationsWithEmptyResponse() {
        // Given
        mockService.mockStations = []
        
        // When
        let expectation = self.expectation(description: "Empty response handled")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after empty response")
            XCTAssertNil(self.viewModel.errorMessage, "Error message should be nil for empty response")
            XCTAssertEqual(self.viewModel.stations.count, 0, "Should have no stations for empty response")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateDuringFetch() {
        // Given
        let expectation = self.expectation(description: "Loading state verified")
        
        // When
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then - Check loading state immediately after fetch
        XCTAssertTrue(viewModel.isLoading, "Should be loading immediately after fetch")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil during loading")
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading, "Should not be loading after completion")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Service Integration Tests
    
    func testServiceCalledWithCorrectParameters() {
        // Given
        let testLatitude = 37.7749
        let testLongitude = -122.4194
        
        // When
        viewModel.fetchStations(latitude: testLatitude, longitude: testLongitude)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.fetchCalled, "Service fetch method should be called")
            XCTAssertEqual(self.mockService.lastLatitude, testLatitude, "Latitude should be passed correctly")
            XCTAssertEqual(self.mockService.lastLongitude, testLongitude, "Longitude should be passed correctly")
            XCTAssertEqual(self.mockService.lastDistance, 10.0, "Distance should use default value")
        }
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessageClearedOnNewFetch() {
        // Given - First fetch with error
        mockService.shouldReturnError = true
        let expectation1 = self.expectation(description: "First fetch with error")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.errorMessage, "Should have error message after failed fetch")
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        // When - Second fetch with success
        mockService.shouldReturnError = false
        mockService.mockStations = [createMockStation(id: 1, title: "Test", address: "Test", latitude: 1.0, longitude: 2.0, distance: 0.5)]
        let expectation2 = self.expectation(description: "Second fetch with success")
        viewModel.fetchStations(latitude: 1.0, longitude: 2.0)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.errorMessage, "Error message should be cleared on successful fetch")
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Helper Methods

extension ChargingStationsViewModelTests {
    func createMockStation(id: Int, title: String, address: String, latitude: Double, longitude: Double, distance: Double) -> ChargingStation {
        let mockJSON = """
        {
            "ID": \(id),
            "AddressInfo": {
                "Title": "\(title)",
                "AddressLine1": "\(address)",
                "Latitude": \(latitude),
                "Longitude": \(longitude)
            },
            "Distance": \(distance)
        }
        """.data(using: .utf8)!
        
        do {
            return try JSONDecoder().decode(ChargingStation.self, from: mockJSON)
        } catch {
            fatalError("Failed to create mock station: \(error)")
        }
    }
} 
