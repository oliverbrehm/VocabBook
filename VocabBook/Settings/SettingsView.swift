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
    @EnvironmentObject var legacyDataMigrator: LegacyDataMigrator

    // MARK: - State
    @State var triedIcloudMigration = false
}

// MARK: - Actions
extension SettingsView {
    private func tryiCloudMigration() {
        triedIcloudMigration = true
        legacyDataMigrator.tryMigrateiCloudData()
    }
}

// MARK: - UI
extension SettingsView {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if !legacyDataMigrator.icloudMigrated, !triedIcloudMigration {
                    Button("Recover iCloud data", action: tryiCloudMigration)
                    
                    Text("If there is any iCloud data available, you can manually recover it here. iCloud will not be available immedeately after installation or an app update. If nothing happens, please try again in a few minutes.")
                        .font(.footnote)
                }
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LegacyDataMigrator(modelContext: PreviewContainer().modelContainer.mainContext))
    }
}
