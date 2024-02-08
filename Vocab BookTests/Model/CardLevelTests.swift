//
//  CardLevelTests.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 08.02.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import XCTest
@testable import Vocab_Book

final class CardLevelTests: XCTestCase {
    func testTimeIntervalUntilDue() throws {
        CardLevel.allCases.forEach {
            // test time interval is whole day
            XCTAssertEqual(Int($0.timeIntervalUntilDue) % (60 * 60 * 24), 0)
        }
    }
}
