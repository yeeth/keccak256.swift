import XCTest
@testable import keccak256

final class keccak256Tests: XCTestCase {

    func testFoo() {
        let t = "testing".data(using: .utf8)!
//        print(t)

        print(keccak256.hash(t))
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//        XCTAssertEqual(keccak256_swift().text, "Hello, World!")
//    }
//
//    static var allTests = [
//        ("testExample", testExample),
//    ]
}
