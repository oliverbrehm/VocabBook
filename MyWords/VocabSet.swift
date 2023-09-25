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

    var isFavorite: Bool = false
    var cards: [VocabCard] = []

    init(name: String, descriptionText: String) {
        self.name = name
        self.descriptionText = descriptionText
    }
}
