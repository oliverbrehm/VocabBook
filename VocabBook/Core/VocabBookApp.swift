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
    let modelContainer: ModelContainer
    @ObservedObject var legacyDataMigrator: LegacyDataMigrator

    @MainActor
    init() {
        do {
            modelContainer = try ModelContainer(for: VocabSet.self, VocabCard.self)
        } catch {
            fatalError(error.localizedDescription)
        }

        legacyDataMigrator = LegacyDataMigrator(modelContext: modelContainer.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(legacyDataMigrator)
                .modelContainer(modelContainer)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        legacyDataMigrator.migrateLegacyDocuments()
                    }
                }
        }
    }
}
