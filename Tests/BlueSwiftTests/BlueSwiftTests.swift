import XCTest
@testable import BlueSwift

final class BlueSwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BlueSwift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
