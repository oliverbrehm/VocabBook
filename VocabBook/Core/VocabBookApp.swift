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
    let databaseService = DatabaseService()

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { _, _ in }
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(databaseService)
                .modelContainer(databaseService.modelContainer)
        }
    }
}
