//
//  VocabLearnViewModelTests.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 01.03.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import XCTest
@testable import Vocab_Book

final class VocabLearnViewModelTests: XCTestCase {
    func testEmpty() throws {
        let sut = VocabLearnViewModel(cards: [], coverType: .front)

        XCTAssertEqual(sut.nRemaining, 0)
        XCTAssertEqual(sut.nRight, 0)
        XCTAssertEqual(sut.nWrong, 0)
    }

    func testLearn() throws {
        let sut = VocabLearnViewModel(
            cards: [
                VocabCard(front: "1", back: ""),
                VocabCard(front: "2", back: ""),
                VocabCard(front: "3", back: "")
            ],
            coverType: .front
        )

        XCTAssertEqual(sut.nTotal, 3)

        XCTAssertEqual(sut.currentCard?.front, "1")
        XCTAssertEqual(sut.nRemaining, 3)
        XCTAssertEqual(sut.nRight, 0)
        XCTAssertEqual(sut.nWrong, 0)

        sut.uncover()
        sut.guessedRight()

        XCTAssertEqual(sut.currentCard?.front, "2")
        XCTAssertEqual(sut.nRemaining, 2)
        XCTAssertEqual(sut.nRight, 1)
        XCTAssertEqual(sut.nWrong, 0)

        sut.uncover()
        sut.guessedWrong()

        XCTAssertEqual(sut.currentCard?.front, "3")
        XCTAssertEqual(sut.nRemaining, 1)
        XCTAssertEqual(sut.nRight, 1)
        XCTAssertEqual(sut.nWrong, 1)

        sut.uncover()
        sut.guessedWrong()

        XCTAssertNil(sut.currentCard)
        XCTAssertEqual(sut.nRemaining, 0)
        XCTAssertEqual(sut.nRight, 1)
        XCTAssertEqual(sut.nWrong, 2)
    }

    func testFrontCoverd() throws {
        let sut = VocabLearnViewModel(cards: [VocabCard(front: "", back: "")], coverType: .front)
        XCTAssertTrue(sut.coverFront)
        XCTAssertFalse(sut.coverBack)

        sut.uncover()
        XCTAssertFalse(sut.coverFront)
        XCTAssertFalse(sut.coverBack)

        sut.guessedRight()
        XCTAssertTrue(sut.coverFront)
        XCTAssertFalse(sut.coverBack)
    }

    func testBackCoverd() throws {
        let sut = VocabLearnViewModel(cards: [VocabCard(front: "", back: "")], coverType: .back)
        XCTAssertTrue(sut.coverBack)
        XCTAssertFalse(sut.coverFront)

        sut.uncover()
        XCTAssertFalse(sut.coverBack)
        XCTAssertFalse(sut.coverFront)

        sut.guessedRight()
        XCTAssertTrue(sut.coverBack)
        XCTAssertFalse(sut.coverFront)
    }
}
