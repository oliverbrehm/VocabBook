//
//  SettingsView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 04.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var databaseService: DatabaseService
    @EnvironmentObject var legacyDataMigrator: LegacyDataMigrator

    // MARK: - State
    @State var triedIcloudMigration = false
    @AppStorage("useAppBadgeCount") var useAppBadgeCount = false
    @AppStorage("storeDatabaseInCloud") var storeDatabaseInCloud = false
}

// MARK: - Actions
extension SettingsView {
    private func tryiCloudMigration() {
        triedIcloudMigration = true
        legacyDataMigrator.tryMigrateiCloudData()
        dismiss()
    }
}

// MARK: - UI
extension SettingsView {
    var body: some View {
        Form {
            if !legacyDataMigrator.icloudMigrated, !triedIcloudMigration {
                Section {
                    Button("Recover iCloud data from older app version", action: tryiCloudMigration)

                    Text("If there is any iCloud data missing from an older app version, you can manually recover it here. iCloud will not be available immedeately after installation or an app update. If nothing happens, please try again in a few minutes.")
                        .font(.footnote)
                }
            }

            Section {
                Toggle("Use app badge:", isOn: $useAppBadgeCount)
                    .onChange(of: useAppBadgeCount) {
                        if !useAppBadgeCount {
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    }
                Text("If enabled, the app badge will show the number of due cards.")
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LegacyDataMigrator(modelContext: PreviewContainer().modelContainer.mainContext, deleteDuplicatesAction: {}))
            .environmentObject(DatabaseService())
    }
}
