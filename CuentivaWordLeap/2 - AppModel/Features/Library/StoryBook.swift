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
