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
    var name = ""
    var descriptionText = ""
    var language = ""
    var region = ""
    var isFavorite = true

    @Relationship(deleteRule: .cascade)
    var cards: [VocabCard]? = []

    var hasDueCards: Bool {
        (cards ?? []).contains { $0.isDue }
    }

    var dueCards: [VocabCard] {
        (cards ?? []).filter { $0.isDue }
    }

    var setLanguage: SetLanguage {
        get {
            SetLanguage(languageIdentifier: language, regionIdentifier: region)
        }

        set {
            language = newValue.languageIdentifier
            region = newValue.regionIdentifier
        }
    }

    init(name: String, descriptionText: String, language: String, region: String) {
        self.name = name
        self.descriptionText = descriptionText
        self.language = language
        self.region = region
    }

    init() {
        self.name = ""
        self.descriptionText = ""
        self.language = "en"
        self.region = "GB"
    }
}
