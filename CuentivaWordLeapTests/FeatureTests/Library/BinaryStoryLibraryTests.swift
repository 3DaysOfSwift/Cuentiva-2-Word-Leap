import Foundation
import Testing
@testable import CuentivaWordLeap

struct BinaryStoryLibraryTests {
    private var resources: Bundle {
        #if SWIFT_PACKAGE
        Bundle.module
        #else
        Bundle.main
        #endif
    }

    private func resource(_ name: String, _ ext: String) throws -> Data {
        try Data(contentsOf: #require(resources.url(forResource: name, withExtension: ext)))
    }

    @Test func binaryPreservesEveryBookPassageTranslationAndCoverInOrder() throws {
        let covers = try JSONDecoder().decode([String: StoryBookCover].self,
            from: resource("metadata", "json"))
        let original = try CuentivaBookRepository.decode(resource("stories", "txt"), covers: covers)
        let library = try BinaryStoryLibrary(data: resource("Library", "dat"))
        let compiled = try library.books()
        #expect(library.count == 52)
        #expect(compiled == original)
        #expect(compiled.map(\.platformCount) == original.map(\.platformCount))
        #expect(throws: CocoaError.self) { try library.book(at: -1) }
        #expect(throws: CocoaError.self) { try library.book(at: library.count) }
    }

    @Test(arguments: [0, 7, 15, 16, 167])
    func truncatedDataIsRejected(length: Int) throws {
        let data = try resource("Library", "dat")
        #expect(throws: CocoaError.self) { try BinaryStoryLibrary(data: Data(data.prefix(length))).books() }
    }

    @Test(arguments: ["magic", "version", "count", "stringOffset", "stringLength",
                      "utf8", "sentenceCount", "requiredSentences", "optionalSentences", "duplicateID"])
    func corruptTablesAreRejectedWithoutReadingOutsideTheFile(fault: String) throws {
        var data = try resource("Library", "dat")
        switch fault {
        case "magic": data[0] = 0
        case "version": setWord(3, at: 8, in: &data)
        case "count": setWord(.max, at: 12, in: &data)
        case "stringOffset": setWord(.max, at: 16, in: &data)
        case "stringLength": setWord(.max, at: 20, in: &data)
        case "utf8":
            let offset = data.withUnsafeBytes { UInt32(littleEndian: $0.loadUnaligned(fromByteOffset: 16, as: UInt32.self)) }
            data[Int(offset)] = 0xff
        case "sentenceCount": setWord(.max, at: 16 + 100, in: &data)
        case "requiredSentences": setWord(.max, at: 16 + 96, in: &data)
        case "optionalSentences": setWord(1, at: 16 + 116, in: &data)
        case "duplicateID":
            let firstID = data.subdata(in: 16..<24)
            data.replaceSubrange(168..<176, with: firstID)
        default: Issue.record("Unexpected corruption case")
        }
        #expect(throws: CocoaError.self) { try BinaryStoryLibrary(data: data).books() }
    }

    private func setWord(_ value: UInt32, at offset: Int, in data: inout Data) {
        for byte in 0..<4 { data[offset + byte] = UInt8(truncatingIfNeeded: value >> (byte * 8)) }
    }
}
