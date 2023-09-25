//
//  VocabCard.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

@Model
class VocabCard: Identifiable {
    let id = UUID()

    var front: String
    var back: String

    var level = CardLevel.level0

    init(front: String, back: String) {
        self.front = front
        self.back = back
    }

    func increaseLevel() {
        level = level.nextLevel
    }

    func resetLevel() {
        level = .level0
    }
}
