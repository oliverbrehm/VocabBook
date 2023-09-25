//
//  CardLevel.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

enum CardLevel: UInt8, Codable {
    case level0 = 0
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5

    var nextLevel: CardLevel {
        CardLevel(rawValue: rawValue + 1) ?? .level5
    }
}
