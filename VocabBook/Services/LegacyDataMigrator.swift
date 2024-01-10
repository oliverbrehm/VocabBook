//
//  LegacyDataMigrator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 09.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

final class LegacyDataMigrator: ObservableObject {
    // MARK: - Private properties
    private let legacyDocumentManager = VBDocumentManager()
    private let modelContext: ModelContext
    private let deleteDuplicatesAction: @MainActor () async -> Void

    // MARK: - Initializers
    init(modelContext: ModelContext, deleteDuplicatesAction: @MainActor @escaping () async -> Void) {
        self.modelContext = modelContext
        self.deleteDuplicatesAction = deleteDuplicatesAction
    }

    // MARK: - Functions
    @MainActor
    func migrateLegacyDocuments() async {
        legacyDocumentManager.openLocalDocument()

        await migrateData()
        await deleteDuplicatesAction()

        legacyDocumentManager.openiCloudDocument()

        await migrateData()
        await deleteDuplicatesAction()
    }

    // MARK: - Private functions
    @MainActor
    private func migrateData() async {
        let managedObjectContext = legacyDocumentManager.document.managedObjectContext
        let setRequest = NSFetchRequest<WordSet>(entityName: "WordSet")

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                do {
                    let sets = try managedObjectContext.fetch(setRequest)

                    for set in sets {
                        guard !set.name.isEmpty else { continue }

                        let vocabSet = VocabSet(name: set.name, descriptionText: set.descriptionText, language: set.language)
                        vocabSet.isFavorite = set.isFavourite.boolValue
                        self.modelContext.insert(vocabSet)

                        for word in set.words {
                            guard let word = word as? Word else { continue }

                            let vocabCard = VocabCard(front: word.name, back: word.translations, lastLearnedDate: word.lastQuizzedDate)
                            vocabCard.level = CardLevel(rawValue: word.level.uint8Value) ?? .level0

                            self.modelContext.insert(vocabCard)
                            vocabSet.cards?.append(vocabCard)
                        }
                    }

                    continuation.resume(returning: ())
                } catch {
                    print("fetch error: \(error)")
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
