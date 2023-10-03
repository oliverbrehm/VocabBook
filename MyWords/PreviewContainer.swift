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

    let vocabSet: VocabSet
    let vocabCard: VocabCard

    init() {
        guard let container = try? ModelContainer(
            for: VocabSet.self, VocabCard.self,
            configurations: .init(isStoredInMemoryOnly: true)
        ) else {
            fatalError("Error creating preview model container.")
        }

        modelContainer = container
        vocabSet = VocabSet(
            name: "German",
            descriptionText: "This is a test set for view previews. It contains a few german words to simulate learning."
        )
        container.mainContext.insert(vocabSet)

        vocabCard = VocabCard(front: "Potato", back: "Kartoffel")

        let cards = [
            vocabCard,
            VocabCard(front: "Chair", back: "Stuhl\nTest"),
            VocabCard(front: "to work", back: "arbeiten\nTest\nTest"),
            VocabCard(front: "to cook", back: "kochen"),
            VocabCard(front: "vacation", back: "Urlaub\nFerien")
        ]

        for card in cards {
            vocabSet.cards.append(card)
            container.mainContext.insert(card)
        }
    }

    func newCard() -> VocabCard {
        let card = VocabCard(front: "", back: "")
        modelContainer.mainContext.insert(card)
        return card
    }
}
