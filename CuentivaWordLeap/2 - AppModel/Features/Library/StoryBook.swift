import Foundation

struct StoryBook: Identifiable, Hashable, Sendable {
    let id: String
    let storyteller: String
    let title: String
    let englishTitle: String
    let spanishPassages: [String]
    var englishPassages: [String] = []
    var cover: StoryBookCover = StoryBookCover()

    var platformCount: Int { spanishPassages.flatMap(SpanishWordTokenizer.platformTokens).count }
    var characterProfile: GameCharacter? { GameCharacter.storyteller(named: storyteller) }

    var portraitAssetName: String {
        characterProfile?.portraitAssetName ?? "StorytellerMora"
    }

    /// Stable book IDs keep scenery attached to its story if catalogue order changes.
    /// The remaining books deliberately retain the original sky until their art is added.
    var backgroundAssetName: String {
        switch id {
        case "cafe": "BookBackgroundCafe"
        case "garden": "BookBackgroundGarden"
        case "train": "BookBackgroundTrain"
        case "sea": "BookBackgroundSea"
        case "repair": "BookBackgroundRepair"
        case "repair-hour": "BookBackgroundRepairHour"
        case "loan-notebook": "BookBackgroundLoanNotebook"
        case "small-guide": "BookBackgroundSmallGuide"
        case "three-paths": "BookBackgroundThreePaths"
        case "three-envelopes": "BookBackgroundThreeEnvelopes"
        default: "WordLeapSky"
        }
    }
}

struct StoryBookCover: Codable, Hashable, Sendable {
    var level = "A1"
    var symbol = "book.closed"
    var palette = 0
}

enum SpanishWordTokenizer {
    static func platformTokens(_ passage: String) -> [String] {
        var tokens: [String] = []
        var word = ""
        for character in passage {
            if character.isLetter {
                word.append(character)
            } else {
                if !word.isEmpty {
                    tokens.append(word)
                    word = ""
                }
                if character == "." { tokens.append(".") }
            }
        }
        if !word.isEmpty { tokens.append(word) }
        return tokens
    }
}
