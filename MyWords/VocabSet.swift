//
//  VocabSet.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

@Model
class VocabSet: Identifiable {
    let id = UUID()

    var name: String
    var descriptionText: String

    var isFavorite = false

    @Relationship(deleteRule: .cascade)
    var cards: [VocabCard] = []

    var hasDueCards: Bool {
        cards.contains { $0.isDue }
    }

    init(name: String, descriptionText: String) {
        self.name = name
        self.descriptionText = descriptionText
    }
}
