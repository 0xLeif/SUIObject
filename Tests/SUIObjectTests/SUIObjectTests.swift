import XCTest
@testable import SUIObject

final class SUIObjectTests: XCTestCase {
    func testExample() {
        let object = Object("Hello, World!")
        
        XCTAssertEqual(object.stringValue(), "Hello, World!")
        
        object.add(value: "...")
        
        XCTAssertNotEqual(object.stringValue(), "Hello, World!")
        XCTAssertEqual(object.stringValue(), "...")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
