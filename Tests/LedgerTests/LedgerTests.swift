import XCTest
@testable import Ledger

final class LedgerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Ledger().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
