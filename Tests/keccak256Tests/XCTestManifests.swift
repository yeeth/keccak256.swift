import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(keccak256Tests.allTests),
    ]
}
#endif
