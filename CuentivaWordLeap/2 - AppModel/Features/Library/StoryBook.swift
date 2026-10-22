import Foundation

struct StoryBook: Identifiable, Hashable, Sendable {
    let id: String
    let storyteller: String
    let title: String
    let englishTitle: String
    let spanishPassages: [String]

    var wordCount: Int { spanishPassages.flatMap(SpanishWordTokenizer.words).count }
    var portraitAssetName: String {
        switch storyteller {
        case "Pipa": "StorytellerPipa"
        case "Brasa": "StorytellerBrasa"
        case "Musgo": "StorytellerMusgo"
        case "Zumi": "StorytellerZumi"
        case "Luma": "StorytellerLuma"
        case "Nube": "StorytellerNube"
        case "Tilo": "StorytellerTilo"
        case "Mora": "StorytellerMora"
        case "Faro": "StorytellerFaro"
        default: "StorytellerMora"
        }
    }
}

enum SpanishWordTokenizer {
    static func words(_ passage: String) -> [String] {
        passage.components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
    }
}
