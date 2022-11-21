import XCTest
@testable import PaymentLedger

final class PaymentLedgerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Ledger().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
