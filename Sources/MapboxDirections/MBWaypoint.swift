/**
 A `Waypoint` object indicates a location along a route. It may be the route’s origin or destination, or it may be another location that the route visits. A waypoint object indicates the location’s geographic location along with other optional information, such as a name or the user’s direction approaching the waypoint. You create a `RouteOptions` object using waypoint objects and also receive waypoint objects in the completion handler of the `Directions.calculate(_:completionHandler:)` method.
 */
public class Waypoint: Codable {

    // MARK: Creating a Waypoint Object
    
    private enum CodingKeys: String, CodingKey {
        case coordinate = "location"
        case coordinateAccuracy
        case name
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        coordinateAccuracy = try container.decodeIfPresent(CLLocationAccuracy.self, forKey: .coordinateAccuracy) ?? -1
        
        if let name = try container.decodeIfPresent(String.self, forKey: .name),
            !name.isEmpty {
            self.name = name
        } else {
            name = nil
        }
    }
    
    /**
     Initializes a new waypoint object with the given geographic coordinate and an optional accuracy and name.
     
     - parameter coordinate: The geographic coordinate of the waypoint.
     - parameter coordinateAccuracy: The maximum distance away from the waypoint that the route may come and still be considered viable. This parameter is measured in meters. A negative value means the route may be an indefinite number of meters away from the route and still be considered viable.
        
        It is recommended that the value of this parameter be greater than the `horizontalAccuracy` property of a `CLLocation` object obtained from a `CLLocationManager` object. There is a high likelihood that the user may be located some distance away from a navigable road, for instance if the user is currently on a driveway or inside a building.
     - parameter name: The name of the waypoint. This parameter does not affect the route but may help you to distinguish one waypoint from another.
     */
    public init(coordinate: CLLocationCoordinate2D, coordinateAccuracy: CLLocationAccuracy = -1, name: String? = nil) {
        self.coordinate = coordinate
        self.coordinateAccuracy = coordinateAccuracy
        self.name = name
    }
    
    #if os(tvOS) || os(watchOS)
    /**
     Initializes a new waypoint object with the given `CLLocation` object and an optional heading value and name.
     
     - note: This initializer is intended for `CLLocation` objects created using the `CLLocation.init(latitude:longitude:)` initializer. If you intend to use a `CLLocation` object obtained from a `CLLocationManager` object, consider increasing the `horizontalAccuracy` or set it to a negative value to avoid overfitting, since the `Waypoint` class’s `coordinateAccuracy` property represents the maximum allowed deviation from the waypoint. There is a high likelihood that the user may be located some distance away from a navigable road, for instance if the user is currently on a driveway of inside a building.
     
     - parameter location: A `CLLocation` object representing the waypoint’s location. This initializer respects the `CLLocation` class’s `coordinate` and `horizontalAccuracy` properties, converting them into the `coordinate` and `coordinateAccuracy` properties, respectively.
     - parameter heading: A `CLLocationDirection` value representing the direction from which the route must approach the waypoint in order to be considered viable. This value is stored in the `headingAccuracy` property.
     - parameter name: The name of the waypoint. This parameter does not affect the route but may help you to distinguish one waypoint from another.
     */
    public init(location: CLLocation, heading: CLLocationDirection? = nil, name: String? = nil) {
        coordinate = location.coordinate
        coordinateAccuracy = location.horizontalAccuracy
        if let heading = heading , heading >= 0 {
            self.heading = heading
        }
        self.name = name
    }
    #else
    /**
     Initializes a new waypoint object with the given `CLLocation` object and an optional `CLHeading` object and name.
     
     - note: This initializer is intended for `CLLocation` objects created using the `CLLocation.init(latitude:longitude:)` initializer. If you intend to use a `CLLocation` object obtained from a `CLLocationManager` object, consider increasing the `horizontalAccuracy` or set it to a negative value to avoid overfitting, since the `Waypoint` class’s `coordinateAccuracy` property represents the maximum allowed deviation from the waypoint. There is a high likelihood that the user may be located some distance away from a navigable road, for instance if the user is currently on a driveway of inside a building.
     
     - parameter location: A `CLLocation` object representing the waypoint’s location. This initializer respects the `CLLocation` class’s `coordinate` and `horizontalAccuracy` properties, converting them into the `coordinate` and `coordinateAccuracy` properties, respectively.
     - parameter heading: A `CLHeading` object representing the direction from which the route must approach the waypoint in order to be considered viable. This initializer respects the `CLHeading` class’s `trueHeading` property or `magneticHeading` property, converting it into the `headingAccuracy` property.
     - parameter name: The name of the waypoint. This parameter does not affect the route but may help you to distinguish one waypoint from another.
     */
    public init(location: CLLocation, heading: CLHeading? = nil, name: String? = nil) {
        coordinate = location.coordinate
        coordinateAccuracy = location.horizontalAccuracy
        if let heading = heading {
            self.heading = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
        }
        self.name = name
    }
    #endif
    
    public func copy(with zone: NSZone?) -> Any {
        var copy = Waypoint(coordinate: coordinate, coordinateAccuracy: coordinateAccuracy, name: name)
        copy.heading = heading
        copy.headingAccuracy = headingAccuracy
        return copy
    }
    
    // MARK: Getting the Waypoint’s Location
    
    /**
     The geographic coordinate of the waypoint.
     */
    public let coordinate: CLLocationCoordinate2D
    
    /**
     The radius of uncertainty for the waypoint, measured in meters.
     
     For a route to be considered viable, it must enter this waypoint’s circle of uncertainty. The `coordinate` property identifies the center of the circle, while this property indicates the circle’s radius. If the value of this property is negative, a route is considered viable regardless of whether it enters this waypoint’s circle of uncertainty, subject to an undefined maximum distance.
     
     By default, the value of this property is a negative number.
     */
    public var coordinateAccuracy: CLLocationAccuracy = -1
    
    // MARK: Getting the Direction of Approach
    
    /**
     The direction from which a route must approach this waypoint in order to be considered viable.
     
     This property is measured in degrees clockwise from true north. A value of 0 degrees means due north, 90 degrees means due east, 180 degrees means due south, and so on. If the value of this property is negative, a route is considered viable regardless of the direction from which it approaches this waypoint.
     
     If this waypoint is the first waypoint (the source waypoint), the route must start out by heading in the direction specified by this property. You should always set the `headingAccuracy` property in conjunction with this property. If the `headingAccuracy` property is set to a negative value, this property is ignored.
     
     For driving directions, this property can be useful for avoiding a route that begins by going in the direction opposite the current direction of travel. For example, if you know the user is moving eastwardly and the first waypoint is the user’s current location, specifying a heading of 90 degrees and a heading accuracy of 90 degrees for the first waypoint avoids a route that begins with a “head west” instruction.
     
     You should be certain that the user is in motion before specifying a heading and heading accuracy; otherwise, you may be unnecessarily filtering out the best route. For example, suppose the user is sitting in a car parked in a driveway, facing due north, with the garage in front and the street to the rear. In that case, specifying a heading of 0 degrees and a heading accuracy of 90 degrees may result in a route that begins on the back alley or, worse, no route at all. For this reason, it is recommended that you only specify a heading and heading accuracy when automatically recalculating directions due to the user deviating from the route.
     
     By default, the value of this property is a negative number, meaning that a route is considered viable regardless of the direction of approach.
     */
    public var heading: CLLocationDirection = -1
    
    /**
     The maximum amount, in degrees, by which a route’s approach to a waypoint may differ from `heading` in either direction in order to be considered viable.
     
     A value of 0 degrees means that the approach must match the specified `heading` exactly – an unlikely scenario. A value of 180 degrees or more means that the approach may be as much as 180 degrees in either direction from the specified `heading`, effectively allowing a candidate route to approach the waypoint from any direction.
     
     If you set the `heading` property, you should set this property to a value such as 90 degrees, to avoid filtering out routes whose approaches differ only slightly from the specified `heading`. Otherwise, if the `heading` property is set to a negative value, this property is ignored.
     
     By default, the value of this property is a negative number, meaning that a route is considered viable regardless of the direction of approach.
     */
    public var headingAccuracy: CLLocationDirection = -1
    
    internal var headingDescription: String {
        return heading >= 0 && headingAccuracy >= 0 ? "\(heading.truncatingRemainder(dividingBy: 360)),\(min(headingAccuracy, 180))" : ""
    }
    
    /**
     A boolean value indicating whether arriving on opposite side is allowed.
     This property has no effect if `DirectionsOptions.includesSteps` is set to `false`.
     This property corresponds to the [`approaches`](https://www.mapbox.com/api-documentation/navigation/#retrieve-directions) query parameter in the Mapbox Directions and Map Matching APIs.
     */
    @objc open var allowsArrivingOnOppositeSide = true
    
    // MARK: Identifying the Waypoint
    
    /**
     The name of the waypoint.
     
     This parameter does not affect the route, but you can set the name of a waypoint you pass into a `RouteOptions` object to help you distinguish one waypoint from another in the array of waypoints passed into the completion handler of the `Directions.calculate(_:completionHandler:)` method.
     */
    public var name: String?
    
    /**
     A Boolean value indicating whether the waypoint is significant enough to appear in the resulting routes as a waypoint separating two legs, along with corresponding guidance instructions.
     
     By default, this property is set to `true`, which means that each resulting route will include a leg that ends by arriving at the waypoint as `RouteLeg.destination` and a subsequent leg that begins by departing from the waypoint as `RouteLeg.source`. Otherwise, if this property is set to `false`, a single leg passes through the waypoint without specifically mentioning it. Regardless of the value of this property, each resulting route passes through the location specified by the `coordinate` property, accounting for approach-related properties such as `heading`.
     
     With the Mapbox Directions API, set this property to `false` if you want the waypoint’s location to influence the path that the route follows without attaching any meaning to the waypoint object itself. With the Mapbox Map Matching API, use this property when the `DirectionsOptions.includesSteps` property is `true` or when `coordinates` represents a trace with a high sample rate.
     This property has no effect if `DirectionsOptions.includesSteps` is set to `false`, or if `MatchOptions.waypointIndices` is non-nil.
     This property corresponds to the [`approaches`](https://docs.mapbox.com/api/navigation/#retrieve-directions) query parameter in the Mapbox Directions and Map Matching APIs.
     */
   public var separatesLegs: Bool = true
    
    public var description: String {
        return name ?? "<latitude: \(coordinate.latitude); longitude: \(coordinate.longitude)>"
    }
}

extension Waypoint: Equatable {
    public static func == (lhs: Waypoint, rhs: Waypoint) -> Bool {
        return lhs.coordinate == rhs.coordinate && lhs.name == rhs.name && lhs.coordinateAccuracy == rhs.coordinateAccuracy
    }
}
