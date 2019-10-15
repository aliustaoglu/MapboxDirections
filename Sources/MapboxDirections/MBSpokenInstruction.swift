import Foundation
import CoreLocation


/**
 An instruction about an upcoming `RouteStep`’s maneuver, optimized for speech synthesis.

 The instruction is provided in two formats: plain text and text marked up according to the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML). Use a speech synthesizer such as `AVSpeechSynthesizer` or Amazon Polly to read aloud the instruction.

 The `distanceAlongStep` property is measured from the beginning of the step associated with this object. By contrast, the `text` and `ssmlText` properties refer to the details in the following step. It is also possible for the instruction to refer to two following steps simultaneously when needed for safe navigation.
 */

open class SpokenInstruction: Codable {

    /**
     A distance along the associated `RouteStep` at which to read the instruction aloud.

     The distance is measured in meters from the beginning of the associated step.
     */
    public let distanceAlongStep: CLLocationDistance


    /**
     A plain-text representation of the speech-optimized instruction.

     This representation is appropriate for speech synthesizers that lack support for the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as `AVSpeechSynthesizer`. For speech synthesizers that support SSML, use the `ssmlText` property instead.
     */
    public let text: String


    /**
     A formatted representation of the speech-optimized instruction.

     This representation is appropriate for speech synthesizers that support the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as [Amazon Polly](https://aws.amazon.com/polly/). Numbers and names are marked up to ensure correct pronunciation. For speech synthesizers that lack SSML support, use the `text` property instead.
     */
    public let ssmlText: String
    
     private enum CodingKeys: String, CodingKey {
          case distanceAlongStep = "distanceAlongGeometry"
          case text = "announcement"
          case ssmlText = "ssmlAnnouncement"
      }


    /**
     Initialize a `SpokenInstruction`.

     - parameter distanceAlongStep: A distance along the associated `RouteStep` at which to read the instruction aloud.
     - parameter text: A plain-text representation of the speech-optimized instruction.
     - parameter ssmlText: A formatted representation of the speech-optimized instruction.
     */
    public init(distanceAlongStep: CLLocationDistance, text: String, ssmlText: String) {
        self.distanceAlongStep = distanceAlongStep
        self.text = text
        self.ssmlText = ssmlText
    }
}
