import XCTest

import keccak256Tests

var tests = [XCTestCaseEntry]()
tests += keccak256Tests.allTests()
XCTMain(tests)
