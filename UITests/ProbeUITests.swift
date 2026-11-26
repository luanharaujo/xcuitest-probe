import XCTest

final class ProbeUITests: XCTestCase {
    func testTapChangesLabel() {
        let app = XCUIApplication()
        app.launch()

        let status = app.staticTexts["status"]
        XCTAssertTrue(status.waitForExistence(timeout: 30))
        XCTAssertEqual(status.label, "Waiting")

        app.buttons["tapButton"].tap()
        XCTAssertEqual(status.label, "Tapped")
    }
}
