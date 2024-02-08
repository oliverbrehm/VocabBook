//
//  SetLanguageTests.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 08.02.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import XCTest
@testable import Vocab_Book

final class SetLanguageTests: XCTestCase {
    func testEmojiFlag() throws {
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "gb").emojiFlag, "🇬🇧")
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "us").emojiFlag, "🇺🇸")
        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "de").emojiFlag, "🇩🇪")
        XCTAssertEqual(SetLanguage(languageIdentifier: "fr", regionIdentifier: "fr").emojiFlag, "🇫🇷")
        XCTAssertEqual(SetLanguage(languageIdentifier: "it", regionIdentifier: "it").emojiFlag, "🇮🇹")

        // assert that flag is independent of language
        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "us").emojiFlag, "🇺🇸")
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "de").emojiFlag, "🇩🇪")
    }

    func testLanguageString() throws {
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "gb").languageString, Locale.current.localizedString(forLanguageCode: "en"))
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "us").languageString, Locale.current.localizedString(forLanguageCode: "en"))
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "de").languageString, Locale.current.localizedString(forLanguageCode: "en"))

        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "de").languageString, Locale.current.localizedString(forLanguageCode: "de"))
        XCTAssertEqual(SetLanguage(languageIdentifier: "it", regionIdentifier: "it").languageString, Locale.current.localizedString(forLanguageCode: "it"))
    }

    func testStringWithFlag() throws {
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "gb").stringWithFlag, "🇬🇧 \(Locale.current.localizedString(forLanguageCode: "en") ?? "")")
        XCTAssertEqual(SetLanguage(languageIdentifier: "en", regionIdentifier: "us").stringWithFlag, "🇺🇸 \(Locale.current.localizedString(forLanguageCode: "en") ?? "")")
        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "de").stringWithFlag, "🇩🇪 \(Locale.current.localizedString(forLanguageCode: "de") ?? "")")
        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "it").stringWithFlag, "🇮🇹 \(Locale.current.localizedString(forLanguageCode: "de") ?? "")")

        // test invalid identifiers
        XCTAssertEqual(SetLanguage(languageIdentifier: "de", regionIdentifier: "invalid").stringWithFlag, Locale.current.localizedString(forLanguageCode: "de"))
        XCTAssertEqual(SetLanguage(languageIdentifier: "invalid", regionIdentifier: "de").stringWithFlag, "🇩🇪 invalid")
    }

    func testLanguageList() throws {
        XCTAssert(!SetLanguage.allLanguages().isEmpty)

        XCTAssert(SetLanguage.allLanguages().contains { $0.identifier.lowercased() == "de" })
        XCTAssert(SetLanguage.allLanguages().contains { $0.identifier.lowercased() == "en" })
        XCTAssert(SetLanguage.allLanguages().contains { $0.identifier.lowercased() == "it" })
    }

    func testFlagList() throws {
        let germanRegions = try XCTUnwrap(Locale.Language(identifier: "de").languageCode?.regions)
        XCTAssertLessThan(try XCTUnwrap(germanRegions.firstIndex(of: Locale.Region("de"))), try XCTUnwrap(germanRegions.firstIndex(of: Locale.Region("it"))))

        let italianRegions = try XCTUnwrap(Locale.Language(identifier: "it").languageCode?.regions)
        XCTAssertLessThan(try XCTUnwrap(italianRegions.firstIndex(of: Locale.Region("it"))), try XCTUnwrap(italianRegions.firstIndex(of: Locale.Region("de"))))
    }
}
