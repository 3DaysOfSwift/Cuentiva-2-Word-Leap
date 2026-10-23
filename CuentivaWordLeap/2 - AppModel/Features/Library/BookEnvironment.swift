/// A book can own bespoke scenery or share a reusable environment pack.
/// Selection uses stable book identity, never the catalogue's current order.
enum BookEnvironment: String, CaseIterable, Sendable {
    case coast, roots, railway, puddle, observatory, harbour
    case theatre, orchard, storm, letters, skyFalls

    var backdropAssetName: String {
        switch self {
        case .coast: "CoastBackdrop"
        case .roots: "RootsBackdrop"
        case .railway: "RailwayBackdrop"
        case .puddle: "PuddleBackdrop"
        case .observatory: "ObservatoryBackdrop"
        case .harbour: "HarbourBackdrop"
        case .theatre: "TheatreBackdrop"
        case .orchard: "OrchardBackdrop"
        case .storm: "StormBackdrop"
        case .letters: "LettersBackdrop"
        case .skyFalls: "SkyFallsBackdrop"
        }
    }
}
