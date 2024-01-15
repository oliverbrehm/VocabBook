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
                    let existingSets = try self.modelContext.fetch(FetchDescriptor<VocabSet>()).map { $0.name }

                    let sets = try managedObjectContext.fetch(setRequest)

                    for set in sets {
                        guard let name = set.name, !name.isEmpty, !existingSets.contains(name) else { continue }
                        let descriptionText = set.descriptionText ?? ""
                        let language = set.language ?? ""
                        let isFavorite = set.isFavourite?.boolValue ?? false

                        let vocabSet = VocabSet(name: name, descriptionText: descriptionText, language: language)
                        vocabSet.isFavorite = isFavorite
                        self.modelContext.insert(vocabSet)

                        for word in set.words ?? [] {
                            guard let word = word as? Word, let wordName = word.name else { continue }
                            let wordTranslations = word.translations ?? ""
                            let wordLastQuizzedDate = word.lastQuizzedDate ?? Date()
                            let wordLevel = word.level?.uint8Value ?? 0

                            let vocabCard = VocabCard(front: wordName, back: wordTranslations, lastLearnedDate: wordLastQuizzedDate)
                            vocabCard.level = CardLevel(rawValue: wordLevel) ?? .level0

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
