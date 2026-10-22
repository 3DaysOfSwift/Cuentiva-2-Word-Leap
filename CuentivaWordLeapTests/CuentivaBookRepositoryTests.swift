import Foundation
import Testing
@testable import CuentivaWordLeap

struct CuentivaBookRepositoryTests {
    @Test func decodesBooksAndSpanishPassages() throws {
        let source = """
        @mora-01|Mora|La corona|The Crown|A short tale
        ---
        Mora encuentra una corona. | Mora finds a crown.
        """

        let books = try CuentivaBookRepository.decode(Data(source.utf8))

        #expect(books.count == 1)
        #expect(books[0].title == "La corona")
        #expect(books[0].spanishPassages == ["Mora encuentra una corona."])
    }
}
