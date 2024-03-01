//
//  LanguageSelectViewModelTests.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 01.03.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import XCTest
@testable import Vocab_Book

final class LanguageSelectViewModelTests: XCTestCase {
    func testSetLanguage() throws {
        let sut = LanguageSelectViewModel(vocabSet: VocabSet(name: "name", descriptionText: "descriptionText", language: "de", region: "de"))

        sut.selectedLanugage = "en"
        sut.selectedRegion = "us"

        XCTAssertEqual(sut.vocabSet.language, "en")
        XCTAssertEqual(sut.vocabSet.region, "us")
    }

    func testSearch() throws {
        let sut = LanguageSelectViewModel(vocabSet: VocabSet(name: "name", descriptionText: "descriptionText", language: "de", region: "de"))
        
        XCTAssertEqual(sut.filteredLanguages, SetLanguage.allLanguages)

        sut.searchLanguage = "a"
        XCTAssertNotEqual(sut.filteredLanguages, SetLanguage.allLanguages)

        sut.searchLanguage = ""
        XCTAssertEqual(sut.filteredLanguages, SetLanguage.allLanguages)

        let v = VocabLearnView(cards: [], coverType: .back)
        v.nextCard()
    }
}
