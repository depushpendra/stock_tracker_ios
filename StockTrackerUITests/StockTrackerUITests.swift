import XCTest

final class StockTrackerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStocksListAppearsOnLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Stocks"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["stock_list"].waitForExistence(timeout: 5))
    }

    func testFeedControlIsVisible() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["feed_control_button"].waitForExistence(timeout: 5))
    }

    func testNavigateToSymbolDetail() throws {
        let app = XCUIApplication()
        app.launch()

        let firstRow = app.buttons.matching(NSPredicate(format: "label CONTAINS 'AAPL'")).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()

        XCTAssertTrue(app.navigationBars["AAPL"].waitForExistence(timeout: 5))
    }
}
