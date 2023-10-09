//
//  LegacyDataMigrator.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 09.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

final class LegacyDataMigrator: ObservableObject {
    // MARK: - Properties
    var icloudMigrated: Bool {
        UserDefaults.standard.bool(forKey: "swiftDataMigrationiCloudDone")
    }

    // MARK: - Private properties
    private let legacyDocumentManager = VBDocumentManager()
    private let modelContext: ModelContext

    // MARK: - Initializers
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Functions
    func migrateLegacyDocuments() {
        if !UserDefaults.standard.bool(forKey: "swiftDataMigrationLocalDone") {
            legacyDocumentManager.openLocalDocument()
            migrateData()
            UserDefaults.standard.setValue(true, forKey: "swiftDataMigrationLocalDone")
        }

        if !UserDefaults.standard.bool(forKey: "swiftDataMigrationiCloudDone") {
            tryMigrateiCloudData()
        }
    }

    func tryMigrateiCloudData() {
        legacyDocumentManager.openiCloudDocument()
        if migrateData() {
            UserDefaults.standard.setValue(true, forKey: "swiftDataMigrationiCloudDone")
        }
    }

    // MARK: - Private functions
    /// returns true if records were added to swift data
    @discardableResult
    private func migrateData() -> Bool {
        let managedObjectContext = legacyDocumentManager.document.managedObjectContext
        let setRequest = NSFetchRequest<WordSet>(entityName: "WordSet")

        var hasData = false

        do {
            let sets = try managedObjectContext.fetch(setRequest)

            hasData = !sets.isEmpty

            for set in sets {
                guard !set.name.isEmpty else { continue }

                let vocabSet = VocabSet(name: set.name, descriptionText: set.descriptionText)
                self.modelContext.insert(vocabSet)

                for word in set.words {
                    guard let word = word as? Word else { continue }

                    let vocabCard = VocabCard(front: word.name, back: word.translations)
                    self.modelContext.insert(vocabCard)
                    vocabSet.cards.append(vocabCard)
                }
            }
        } catch {
            print("fetch error: \(error)")
        }

        return hasData
    }
}
