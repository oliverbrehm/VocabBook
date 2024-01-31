//
//  DatabaseService.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 17.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

final class DatabaseService: ObservableObject {
    // MARK: - Properties
    @Published var modelContainer: ModelContainer

    // MARK: - Initializers
    init() {
        do {
            modelContainer = try ModelContainer(for: VocabSet.self, VocabCard.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - Functions
    @MainActor
    func deleteDuplicates() async {
        guard var vocabSets = try? modelContainer.mainContext.fetch(FetchDescriptor<VocabSet>()) else {
            print("Error querying vocab sets in deleteDuplicates.")
            return
        }

        while let duplicate = findDuplicate(in: vocabSets) {
            vocabSets.removeAll { $0.id == duplicate.id }
            modelContainer.mainContext.delete(duplicate)
            try? modelContainer.mainContext.save()
        }

        if let cardsWithoutSets = try? modelContainer.mainContext.fetch(FetchDescriptor<VocabCard>()).filter({ $0.vocabSet == nil }) {
            for card in cardsWithoutSets {
                modelContainer.mainContext.delete(card)
            }
        }
    }

    // MARK: - Private functions
    private func findDuplicate(in sets: [VocabSet]) -> VocabSet? {
        for set in sets where hasDuplicate(of: set, in: sets) {
            return set
        }

        return nil
    }

    private func hasDuplicate(of set: VocabSet, in sets: [VocabSet]) -> Bool {
        sets.filter { $0.name == set.name && $0.cards?.count == set.cards?.count }.count > 1
    }

    @MainActor
    private func createPreviewData() {
        guard let vocabSets = try? modelContainer.mainContext.fetch(FetchDescriptor<VocabSet>()), vocabSets.isEmpty else {
            return
        }

        let set1 = VocabSet(name: "English", descriptionText: "", language: "en", region: "GB")
        modelContainer.mainContext.insert(set1)

        let card11 = VocabCard(front: "racoon", back: "Waschbär")
        let card12 = VocabCard(front: "etw. leugnen", back: "to deny")
        modelContainer.mainContext.insert(card11)
        modelContainer.mainContext.insert(card12)
        card11.vocabSet = set1
        card12.vocabSet = set1

        let set2 = VocabSet(name: "Groceries", descriptionText: "", language: "en", region: "GB")
        modelContainer.mainContext.insert(set2)
        let card21 = VocabCard(front: "blueberry", back: "Blaubeere")
        let card22 = VocabCard(front: "flour", back: "Mehl")
        let card23 = VocabCard(front: "to knead", back: "kneten")
        modelContainer.mainContext.insert(card21)
        modelContainer.mainContext.insert(card22)
        modelContainer.mainContext.insert(card23)
        card21.vocabSet = set2
        card22.vocabSet = set2
        card23.vocabSet = set2

        let set3 = VocabSet(name: "Vacanza", descriptionText: "", language: "it", region: "IT")
        modelContainer.mainContext.insert(set3)
        let card31 = VocabCard(front: "il sole", back: "die Sonne")
        let card32 = VocabCard(front: "nuotare", back: "schwimmen")
        modelContainer.mainContext.insert(card31)
        modelContainer.mainContext.insert(card32)
        card31.vocabSet = set3
        card32.vocabSet = set3
    }
}
