//
//  VocabCard.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

@Model
class VocabCard: Identifiable, Equatable {
    // MARK: - Persisted
    let id = UUID()

    var front = ""
    var back = ""
    var level = CardLevel.level0
    var creationDate = Date()
    var lastLearnedDate = Date()

    @Relationship(inverse: \VocabSet.cards)
    var vocabSet: VocabSet?

    // MARK: - Computed properties
    var isDue: Bool {
        Date() >= lastLearnedDate.advanced(by: level.timeIntervalUntilDue)
    }

    // MARK: - Initializers
    init(front: String, back: String, lastLearnedDate: Date = Date()) {
        self.front = front
        self.back = back
    }

    // MARK: - Functions
    func increaseLevel() {
        guard isDue else { return }

        lastLearnedDate = Date()
        level = level.nextLevel
    }

    func resetLevel() {
        lastLearnedDate = Date()
        level = .level0
    }

    func trim() {
        front = front.trimmingCharacters(in: .whitespacesAndNewlines)
        back = back.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
