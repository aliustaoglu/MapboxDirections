import Foundation


public struct LaneIndication: OptionSet, CustomStringConvertible, Codable {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    
    public typealias RawValue = Int

    /// Indicates a sharp turn to the right.
    static let sharpRight = LaneIndication(rawValue: 1 << 1)
    
    /// Indicates a turn to the right.
    static let right = LaneIndication(rawValue: 1 << 2)
    
    /// Indicates a turn to the right.
    static let slightRight = LaneIndication(rawValue: 1 << 3)
    
    /// Indicates no turn.
    static let straightAhead = LaneIndication(rawValue: 1 << 4)
    
    /// Indicates a slight turn to the left.
    static let slightLeft = LaneIndication(rawValue: 1 << 5)
    
    /// Indicates a turn to the left.
    static let left = LaneIndication(rawValue: 1 << 6)
    
    /// Indicates a sharp turn to the left.
    static let sharpLeft = LaneIndication(rawValue: 1 << 7)
    
    /// Indicates a U-turn.
    static let uTurn = LaneIndication(rawValue: 1 << 8)
    

    /**
     Creates a lane indication from the given description strings.
     */
    public init?(descriptions: [String]) {
        var laneIndication: LaneIndication = []
        for description in descriptions {
            switch description {
            case "sharp right":
                laneIndication.insert(.sharpRight)
            case "right":
                laneIndication.insert(.right)
            case "slight right":
                laneIndication.insert(.slightRight)
            case "straight":
                laneIndication.insert(.straightAhead)
            case "slight left":
                laneIndication.insert(.slightLeft)
            case "left":
                laneIndication.insert(.left)
            case "sharp left":
                laneIndication.insert(.sharpLeft)
            case "uturn":
                laneIndication.insert(.uTurn)
            case "none":
                break
            default:
                return nil
            }
        }
        self.init(rawValue: laneIndication.rawValue)
    }
    
    public var descriptions: [String] {
        if isEmpty {
            return []
        }
        
        var descriptions: [String] = []
        if contains(.sharpRight) {
            descriptions.append("sharp right")
        }
        if contains(.right) {
            descriptions.append("right")
        }
        if contains(.slightRight) {
            descriptions.append("slight right")
        }
        if contains(.straightAhead) {
            descriptions.append("straight")
        }
        if contains(.slightLeft) {
            descriptions.append("slight left")
        }
        if contains(.left) {
            descriptions.append("left")
        }
        if contains(.sharpLeft) {
            descriptions.append("sharp left")
        }
        if contains(.uTurn) {
            descriptions.append("uturn")
        }
        return descriptions
    }
    
    public var description: String {
        return descriptions.joined(separator: ",")
    }
    
    public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let stringValues = try container.decode([String].self)
        
    self = try LaneIndication.indications(from: stringValues, container: container)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(descriptions)
    }
    
    static func indications(from strings: [String], container: SingleValueDecodingContainer) throws -> LaneIndication {
        guard let indications = self.init(descriptions: strings) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to initialize lane indications from decoded string. This should not happen.")
        }
        return indications
    }
}
