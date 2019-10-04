import Foundation
import CoreLocation

/**
 A bounding box represents a geographic region.
 */

public struct CoordinateBounds: Codable {
    let southWest: CLLocationCoordinate2D
    let northEast: CLLocationCoordinate2D
    
    enum CodingKeys: String, CodingKey {
        case southWest, northEast
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        southWest = try container.decode(CLLocationCoordinate2D.self, forKey: .southWest)
        northEast = try container.decode(CLLocationCoordinate2D.self, forKey: .northEast)
    }
    /**
     Initializes a `BoundingBox` with known bounds.
     */
        public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }
    
    /**
     Initializes a `BoundingBox` with known bounds.
     */
        public init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.southWest = CLLocationCoordinate2D(latitude: southEast.latitude, longitude: northWest.longitude)
        self.northEast = CLLocationCoordinate2D(latitude: northWest.latitude, longitude: southEast.longitude)
    }
    
    /**
     Initializes a `BoundingBox` from an array of `CLLocationCoordinate2D`’s.
     */
    public init(coordinates: [CLLocationCoordinate2D]) {
        assert(coordinates.count >= 2, "coordinates must consist of at least two coordinates")
        
        var maximumLatitude: CLLocationDegrees = -90
        var minimumLatitude: CLLocationDegrees = 90
        var maximumLongitude: CLLocationDegrees = -180
        var minimumLongitude: CLLocationDegrees = 180
        
        for coordinate in coordinates {
            maximumLatitude = max(maximumLatitude, coordinate.latitude)
            minimumLatitude = min(minimumLatitude, coordinate.latitude)
            maximumLongitude = max(maximumLongitude, coordinate.longitude)
            minimumLongitude = min(minimumLongitude, coordinate.longitude)
        }
        
        let southWest = CLLocationCoordinate2D(latitude: minimumLatitude, longitude: minimumLongitude)
        let northEast = CLLocationCoordinate2D(latitude: maximumLatitude, longitude: maximumLongitude)
        
        self.init(southWest: southWest, northEast: northEast)
    }
    
    public var description: String {
        return "\(southWest.longitude),\(southWest.latitude);\(northEast.longitude),\(northEast.latitude)"
    }
}
