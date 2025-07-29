import Foundation

struct ChargingStation: Identifiable, Decodable {
    let id: Int
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
    let distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case addressInfo = "AddressInfo"
        case distance = "Distance"
    }
    
    enum AddressInfoCodingKeys: String, CodingKey {
        case title = "Title"
        case addressLine1 = "AddressLine1"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let addressInfo = try container.nestedContainer(keyedBy: AddressInfoCodingKeys.self, forKey: .addressInfo)
        title = (try? addressInfo.decode(String.self, forKey: .title)) ?? "Unknown"
        address = (try? addressInfo.decode(String.self, forKey: .addressLine1)) ?? "Unknown"
        latitude = (try? addressInfo.decode(Double.self, forKey: .latitude)) ?? 0.0
        longitude = (try? addressInfo.decode(Double.self, forKey: .longitude)) ?? 0.0
        distance = try? container.decodeIfPresent(Double.self, forKey: .distance)
    }
} 