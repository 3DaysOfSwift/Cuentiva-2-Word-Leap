/// Cuentiva's cast and game artwork, independent of future collectible ownership.
/// Being in this catalogue does not mean a character has been earned or selected.
struct GameCharacter: Identifiable, Hashable, Sendable {
    /// Stable identity for future collected-character persistence; never derive from display text.
    let id: String
    let name: String
    let species: String
    let biography: String
    let sourceAuthorID: String
    let portraitAssetName: String
    let spriteAssetName: String

    static let cuentivaCast: [GameCharacter] = [
        GameCharacter(id: "pipa", name: "Pipa", species: "Lizard",
            biography: "A curious lizard with a travel notebook and a talent for finding new paths.",
            sourceAuthorID: "marta",
            portraitAssetName: "StorytellerPipa", spriteAssetName: "WordLeapPipa"),
        GameCharacter(id: "brasa", name: "Brasa", species: "Dragon",
            biography: "A little dragon with a generous heart and a weakness for café stories.",
            sourceAuthorID: "ana",
            portraitAssetName: "StorytellerBrasa", spriteAssetName: "WordLeapBrasa"),
        GameCharacter(id: "musgo", name: "Musgo", species: "Woodland wizard",
            biography: "A woodland wizard who finds magic in gardens, family and everyday care.",
            sourceAuthorID: "luis",
            portraitAssetName: "StorytellerMusgo", spriteAssetName: "WordLeapMusgo"),
        GameCharacter(id: "zumi", name: "Zumi", species: "Fly",
            biography: "A tiny fly with enormous curiosity about work, ideas and how things happen.",
            sourceAuthorID: "credit-fade9533cfe2",
            portraitAssetName: "StorytellerZumi", spriteAssetName: "WordLeapZumi"),
        GameCharacter(id: "luma", name: "Luma", species: "Moth",
            biography: "A gentle moth who follows the light of a good idea.",
            sourceAuthorID: "credit-53e13e40b11a",
            portraitAssetName: "StorytellerLuma", spriteAssetName: "WordLeapLuma"),
        GameCharacter(id: "nube", name: "Nube", species: "Cloud creature",
            biography: "A wandering cloud creature with a pocket full of stories and a playful imagination.",
            sourceAuthorID: "credit-5b644d127a59",
            portraitAssetName: "StorytellerNube", spriteAssetName: "WordLeapNube"),
        GameCharacter(id: "tilo", name: "Tilo", species: "Tortoise",
            biography: "A patient tortoise who loves listening to people and bringing their conversations to life.",
            sourceAuthorID: "credit-4ffea73372fb",
            portraitAssetName: "StorytellerTilo", spriteAssetName: "WordLeapTilo"),
        GameCharacter(id: "mora", name: "Mora", species: "Mushroom sprite",
            biography: "A mischievous mushroom sprite who makes words spring into action.",
            sourceAuthorID: "credit-0047224f3651",
            portraitAssetName: "StorytellerMora", spriteAssetName: "WordLeapMora"),
        GameCharacter(id: "faro", name: "Faro", species: "Owl",
            biography: "A curious owl with a map, a satchel and a love of faraway places.",
            sourceAuthorID: "credit-5f7d24711b1b",
            portraitAssetName: "StorytellerFaro", spriteAssetName: "WordLeapFaro")
    ]

    static func storyteller(named name: String) -> GameCharacter? {
        cuentivaCast.first { $0.name == name }
    }
}

