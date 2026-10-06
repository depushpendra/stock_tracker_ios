import XCTest
import Domain
@testable import Core

final class PriceFormattingTests: XCTestCase {
    func testFormatsUSD() {
        let text = PriceFormatting.currency(189.25, currencyCode: .usd, locale: Locale(identifier: "en_US"))
        XCTAssertTrue(text.contains("189"))
        XCTAssertTrue(text.contains("$") || text.contains("USD"))
    }

    func testFormatsAED() {
        let text = PriceFormatting.currency(100, currencyCode: .aed, locale: Locale(identifier: "en_AE"))
        XCTAssertFalse(text.isEmpty)
        XCTAssertTrue(text.contains("100"))
    }

    func testFormatsINR() {
        let text = PriceFormatting.currency(100, currencyCode: .inr, locale: Locale(identifier: "en_IN"))
        XCTAssertFalse(text.isEmpty)
        XCTAssertTrue(text.contains("100"))
    }
}
