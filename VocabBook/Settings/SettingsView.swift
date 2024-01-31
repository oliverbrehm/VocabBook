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
    @State var dataMigrationInProgress = false
}

// MARK: - Actions
extension SettingsView {
    private func migrateLegacyDocuments() {
        dataMigrationInProgress = true

        Task {
            await legacyDataMigrator.migrateLegacyDocuments()

            DispatchQueue.main.async {
                dataMigrationInProgress = false
                dismiss()
            }
        }
    }
}

// MARK: - UI
extension SettingsView {
    var body: some View {
        Form {
            Section {
                if dataMigrationInProgress {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Button(Strings.recoverICloud.localized, action: migrateLegacyDocuments)
                }

                Text(Strings.recoverICloudInfo.localized)
                    .font(.footnote)
            }
        }
        .navigationTitle(Strings.settings.localized)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(LegacyDataMigrator(modelContext: PreviewContainer().modelContainer.mainContext, deleteDuplicatesAction: {}))
        .environmentObject(DatabaseService())
}
