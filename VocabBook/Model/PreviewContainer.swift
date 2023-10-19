//
//  PreviewContainer.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 29.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

@MainActor
struct PreviewContainer {
    let modelContainer: ModelContainer

    var vocabSets: [VocabSet] = []

    var vocabSet: VocabSet? {
        vocabSets.first
    }

    var vocabCard: VocabCard? {
        vocabSet?.cards?.last
    }

    init() {
        guard let container = try? ModelContainer(
            for: VocabSet.self, VocabCard.self,
            configurations: .init(isStoredInMemoryOnly: true)
        ) else {
            fatalError("Error creating preview model container.")
        }

        modelContainer = container

        let vocabSet = VocabSet(
            name: "German",
            descriptionText: "This is a test set for view previews. It contains a few german words to simulate learning.",
            language: "en"
        )
        container.mainContext.insert(vocabSet)
        container.mainContext.insert(VocabSet(name: "French", descriptionText: "French set", language: "fr"))

        vocabSets.append(vocabSet)

        let cards = [
            VocabCard(front: "Potato", back: "Kartoffel"),
            VocabCard(front: "Chair", back: "Stuhl\nTest"),
            VocabCard(front: "to work", back: "arbeiten\nTest\nTest"),
            VocabCard(front: "to cook", back: "kochen"),
            VocabCard(front: "vacation", back: "Urlaub\nFerien")
        ]

        for card in cards {
            modelContainer.mainContext.insert(card)
            vocabSet.cards?.append(card)
        }
    }

    func newCard() -> VocabCard {
        let card = VocabCard(front: "", back: "")
        modelContainer.mainContext.insert(card)
        card.vocabSet = vocabSet
        return card
    }
}
