//
//  VocabSetEditView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 24.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct VocabSetEditView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    @State private var name = ""

    // MARK: - Properties

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
}

// MARK: - Actions
extension VocabSetEditView {

}

// MARK: - UI
extension VocabSetEditView {
    var body: some View {
        Form {
            Section("Name") {
                TextField(text: $name, label: { Text("Name") })
            }
        }
        .navigationTitle("Set")
        .onDisappear {
            if !name.isEmpty {
                modelContext.insert(VocabSet(name: name))
            }
        }
    }
}

// MARK: - Preview
struct VocabSetEditView_Previews: PreviewProvider {
    static var previews: some View {
        VocabSetEditView()
            .modelContainer(for: [VocabSet.self, VocabCard.self], inMemory: true)
    }
}
