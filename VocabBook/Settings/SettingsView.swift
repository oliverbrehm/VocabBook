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
            if !legacyDataMigrator.icloudDataMigrated, !triedIcloudMigration {
                Section {
                    Button(Strings.recoverICloud.localized, action: tryiCloudMigration)

                    Text(Strings.recoverICloudInfo.localized)
                        .font(.footnote)
                }
            }

            Section {
                Toggle("\(Strings.useAppBadge.localized):", isOn: $useAppBadgeCount)
                    .onChange(of: useAppBadgeCount) {
                        if !useAppBadgeCount {
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    }
                Text(Strings.useAppBadgeInfo.localized)
                    .font(.footnote)
            }
        }
        .navigationTitle(Strings.settings.localized)
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
