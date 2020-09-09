import XCTest
@testable import SUIObject

final class SUIObjectTests: XCTestCase {
    func testExample() {
        let object = SUIObject("Hello, World!")
        
        XCTAssertEqual(object.string(), "Hello, World!")
        
        object.add(value: "...")
        
        XCTAssertNotEqual(object.string(), "Hello, World!")
        XCTAssertEqual(object.string(), "...")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
