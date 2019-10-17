import Foundation
import CoreLocation


/**
 A `MatchOptions` object is a structure that specifies the criteria for results returned by the Mapbox Map Matching API.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
open class MatchOptions: DirectionsOptions {

    /**
     Initializes a match options object for matching locations against the road network.

     - parameter locations: An array of `CLLocation` objects representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 25 locations. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(locations: [CLLocation], profileIdentifier: DirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map {
            Waypoint(location: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a match options object for matching geographic coordinates against the road network.

     - parameter coordinates: An array of geographic coordinates representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 25 locations. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).) Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: DirectionsProfileIdentifier? = nil) {
        let waypoints = coordinates.map {
            Waypoint(coordinate: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    public required init(waypoints: [Waypoint], profileIdentifier: DirectionsProfileIdentifier?) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case resamplesTraces = "tidy"
    }
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resamplesTraces, forKey: .resamplesTraces)
        try super.encode(to: encoder)
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resamplesTraces = try container.decode(Bool.self, forKey: .resamplesTraces)
        try super.init(from: decoder)
    }
    /**
     If true, the input locations are re-sampled for improved map matching results. The default is  `false`.
     */
    open var resamplesTraces: Bool = false


    /**
     An index set containing indices of two or more items in `coordinates`. These will be represented by `Waypoint`s in the resulting `Match` objects.

     Use this property when the `DirectionsOptions.includesSteps` property is `true` or when `coordinates` represents a trace with a high sample rate. If this property is `nil`, the resulting `Match` objects contain a waypoint for each coordinate in the match options.

     If specified, each index must correspond to a valid index in `coordinates`, and the index set must contain 0 and the last index (one less than `endIndex`) of `coordinates`.
     */
    @available(*, deprecated, message: "Use Waypoint.separatesLegs instead.")
    open var waypointIndices: IndexSet?
    
    override var legSeparators: [Waypoint] {
        if let indices = (self as MatchOptionsDeprecations).waypointIndices {
            return indices.map { super.waypoints[$0] }
        } else {
            return super.legSeparators
        }
    }

    override open var urlQueryItems: [URLQueryItem] {
        var queryItems = super.urlQueryItems

        queryItems.append(URLQueryItem(name: "tidy", value: String(describing: resamplesTraces)))

        if let waypointIndices = (self as MatchOptionsDeprecations).waypointIndices {
            queryItems.append(URLQueryItem(name: "waypoints", value: waypointIndices.map {
                String(describing: $0)
            }.joined(separator: ";")))
        }

        return queryItems
    }

    internal override var abridgedPath: String {
        return "matching/v5/\(profileIdentifier.rawValue)"
    }
}
private protocol MatchOptionsDeprecations {
    var waypointIndices: IndexSet? { get set }
}
extension MatchOptions: MatchOptionsDeprecations {}

//MARK: - Equatable
public extension MatchOptions {
    static func == (lhs: MatchOptions, rhs: MatchOptions) -> Bool {
            let isSuperEqual = ((lhs as DirectionsOptions) == (rhs as DirectionsOptions))
            return isSuperEqual &&
                lhs.abridgedPath == rhs.abridgedPath &&
                lhs.resamplesTraces == rhs.resamplesTraces
    }
}
