import XCTest
@testable import PasswordStoreSwift

final class PasswordStoreSwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let item = PasswordStore.hasLogIn(for: "www.apple.com")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
