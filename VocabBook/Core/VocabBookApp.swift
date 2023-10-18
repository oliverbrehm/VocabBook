//
//  VocabBookApp.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct VocabBookApp: App {
    @ObservedObject var legacyDataMigrator: LegacyDataMigrator
    let databaseService = DatabaseService()

    @MainActor
    init() {
        legacyDataMigrator = LegacyDataMigrator(modelContext: databaseService.modelContainer.mainContext, deleteDuplicatesAction: databaseService.deleteDuplicates)

        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(databaseService)
                .environmentObject(legacyDataMigrator)
                .modelContainer(databaseService.modelContainer)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        legacyDataMigrator.migrateLegacyDocuments()
                    }
                }
        }
    }
}
