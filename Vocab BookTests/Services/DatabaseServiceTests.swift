//
//  DatabaseServiceTests.swift
//  Vocab BookTests
//
//  Created by Oliver Brehm on 08.02.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import XCTest
import SwiftData
@testable import Vocab_Book

@MainActor
final class DatabaseServiceTests: XCTestCase {
    let databaseService = DatabaseService()

    var modelContext: ModelContext {
        databaseService.modelContainer.mainContext
    }

    override func setUpWithError() throws {
        let vocabSets = try modelContext.fetch(FetchDescriptor<VocabSet>())
        let vocabCards = try modelContext.fetch(FetchDescriptor<VocabCard>())

        vocabSets.forEach { modelContext.delete($0) }
        vocabCards.forEach { modelContext.delete($0) }

        try modelContext.save()

        XCTAssertEqual(try modelContext.fetch(FetchDescriptor<VocabSet>()).count, 0)
        XCTAssertEqual(try modelContext.fetch(FetchDescriptor<VocabCard>()).count, 0)
    }

    func testDeleteDuplicates() async throws {
        modelContext.insert(VocabSet(name: "test", descriptionText: "test", language: "de", region: "de"))
        modelContext.insert(VocabSet(name: "test", descriptionText: "test duplicate", language: "de", region: "de"))

        XCTAssertEqual(try modelContext.fetch(FetchDescriptor<VocabSet>()).count, 2)

        await databaseService.deleteDuplicates()

        XCTAssertEqual(try modelContext.fetch(FetchDescriptor<VocabSet>()).count, 1)
    }

    func testCreatePreviewData() throws {
        databaseService.createPreviewData()

        let vocabSets = try modelContext.fetch(FetchDescriptor<VocabSet>())
        let vocabCards = try modelContext.fetch(FetchDescriptor<VocabCard>())

        XCTAssertEqual(vocabSets.count, 3)
        XCTAssertEqual(vocabCards.count, 7)

        XCTAssertEqual(vocabSets.first { $0.name == "English" }?.cards?.count, 2)
        XCTAssertEqual(vocabSets.first { $0.name == "Groceries" }?.cards?.count, 3)
        XCTAssertEqual(vocabSets.first { $0.name == "Vacanza" }?.cards?.count, 2)
    }
}
