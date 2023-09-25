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
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @Bindable var vocabSet: VocabSet

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
        VStack {
            Form {
                Section("Name") {
                    TextField(text: $vocabSet.name, label: { Text("Name") })
                }

                Section("Description") {
                    TextField(text: $vocabSet.descriptionText, axis: .vertical, label: { Text("Description") })
                }
            }
            .navigationTitle("Edit Set")
        }
    }
}

// MARK: - Preview
struct VocabSetEditView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()
        VocabSetEditView(vocabSet: previewContainer.vocabSet)
            .modelContainer(previewContainer.modelContainer)
    }
}
