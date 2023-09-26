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
    // MARK: - Properties
    let id = UUID()

    var front: String
    var back: String

    var level = CardLevel.level0

    // MARK: - Computed properties
    var isDue: Bool {
        Date() >= lastLearnedDate.advanced(by: level.timeIntervalUntilDue)
    }

    // MARK: - Private properties
    private var lastLearnedDate = Date()

    // MARK: - Initializers
    init(front: String, back: String) {
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
}
