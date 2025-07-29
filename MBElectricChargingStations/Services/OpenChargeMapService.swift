import Foundation

class OpenChargeMapService {
    private let baseURL = "https://api.openchargemap.io/v3/poi/"
    private let apiKey = "4df107b0-89ae-4098-a483-f16e46d70698"
    
    func fetchStations(latitude: Double, longitude: Double, distance: Double = 10, completion: @escaping (Result<[ChargingStation], Error>) -> Void) {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "distance", value: "\(distance)"),
            URLQueryItem(name: "distanceunit", value: "KM"),
            URLQueryItem(name: "maxresults", value: "20"),
            URLQueryItem(name: "compact", value: "true"),
            URLQueryItem(name: "verbose", value: "false"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        print("🌐 Fetching from URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            // Print the raw response to see what we're getting
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw Response (first 500 chars):")
                print(String(responseString.prefix(500)))
                
                // Check if it's an error message
                if responseString.contains("REJECTED") || responseString.contains("ERROR") {
                    print("❌ API Error: \(responseString)")
                    completion(.failure(NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: responseString])))
                    return
                }
            }
            
            do {
                let stations = try JSONDecoder().decode([ChargingStation].self, from: data)
                print("✅ Successfully decoded \(stations.count) stations")
                completion(.success(stations))
            } catch {
                print("❌ JSON Decoding Error: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
} 
