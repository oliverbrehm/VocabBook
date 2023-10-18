//
//  DatabaseService.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 17.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftData

final class DatabaseService: ObservableObject {
    @Published var modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: VocabSet.self, VocabCard.self)
        } catch {
            fatalError(error.localizedDescription)
        }

        Task {
            await deleteDuplicates()
        }
    }

    // MARK: - Functions
    @MainActor
    func deleteDuplicates() {
        guard var vocabSets = try? modelContainer.mainContext.fetch(FetchDescriptor<VocabSet>()) else {
            print("Error querying vocab sets in deleteDuplicates.")
            return
        }

        while let duplicate = findDuplicate(in: vocabSets) {
            modelContainer.mainContext.delete(duplicate)
            vocabSets.removeAll { $0.id == duplicate.id }
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
}
