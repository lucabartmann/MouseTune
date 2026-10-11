@testable import MouseTune
import XCTest

final class ConfigTests: XCTestCase {
    func testEmptyJSONDecodesToDefaults() throws {
        let cfg = try JSONDecoder().decode(Config.self, from: Data("{}".utf8))
        XCTAssertEqual(cfg, Config())
    }

    func testRoundTrip() throws {
        var cfg = Config()
        cfg.scrollSpeed = 2.5
        cfg.language = .de
        cfg.accent = .pink
        cfg.setAction(.copy, forButton: 4)
        let decoded = try JSONDecoder().decode(Config.self, from: JSONEncoder().encode(cfg))
        XCTAssertEqual(decoded, cfg)
        XCTAssertEqual(decoded.action(forButton: 4), .copy)
        XCTAssertEqual(decoded.action(forButton: 5), .passthrough)
    }
}

final class ScrollTests: XCTestCase {
    func testDirectionIsAbsoluteAgainstSystemSetting() {
        XCTAssertEqual(ScrollDirection.system.factor(systemIsNatural: true), 1)
        XCTAssertEqual(ScrollDirection.system.factor(systemIsNatural: false), 1)
        XCTAssertEqual(ScrollDirection.natural.factor(systemIsNatural: true), 1)
        XCTAssertEqual(ScrollDirection.natural.factor(systemIsNatural: false), -1)
        XCTAssertEqual(ScrollDirection.classic.factor(systemIsNatural: true), -1)
        XCTAssertEqual(ScrollDirection.classic.factor(systemIsNatural: false), 1)
    }

    func testSlowFactorKeepsRemainder() {
        var s = ScrollScaler()
        let total = (0..<4).reduce(0.0) { acc, _ in acc + s.scale(1, axis: 0, channel: 0, factor: 0.25) }
        XCTAssertEqual(total, 1)
    }

    func testAxesAreIndependent() {
        var s = ScrollScaler()
        XCTAssertEqual(s.scale(1, axis: 0, channel: 0, factor: 0.5), 0)
        XCTAssertEqual(s.scale(1, axis: 1, channel: 0, factor: 0.5), 0)
        XCTAssertEqual(s.scale(1, axis: 0, channel: 0, factor: 0.5), 1)
    }

    func testNegativeFactorFlipsSign() {
        var s = ScrollScaler()
        XCTAssertEqual(s.scale(3, axis: 0, channel: 1, factor: -2), -6)
    }
}

final class LocalizationTests: XCTestCase {
    func testEveryLanguageCoversEveryKey() {
        for lang in [Language.de, .en] {
            let table = Strings.table(for: lang)
            for key in L10n.allCases {
                XCTAssertFalse(table[key, default: ""].isEmpty, "\(lang) is missing \(key)")
            }
        }
    }

    func testFormatPlaceholdersMatchAcrossLanguages() {
        for key in L10n.allCases {
            let count = { (s: String) in s.components(separatedBy: "%").count }
            XCTAssertEqual(count(Strings.en[key] ?? ""), count(Strings.de[key] ?? ""), "\(key)")
        }
    }

    func testExplicitLanguageResolvesToItself() {
        XCTAssertEqual(Language.de.resolved, .de)
        XCTAssertEqual(Language.en.resolved, .en)
        XCTAssertNotEqual(Language.system.resolved, .system)
    }
}
