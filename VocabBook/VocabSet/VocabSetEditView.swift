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
}

// MARK: - UI
extension VocabSetEditView {
    var body: some View {
        VStack {
            Form {
                Section(Strings.name.localized) {
                    TextField(text: $vocabSet.name, label: { Text(Strings.name.localized) })
                }

                Section(Strings.description.localized) {
                    TextField(text: $vocabSet.descriptionText, axis: .vertical, label: { Text(Strings.description.localized) })
                }

                Section(Strings.language.localized) {
                    NavigationLink {
                        LanguageSelectView(vocabSet: vocabSet)
                    } label: {
                        Text(vocabSet.setLanguage.stringWithFlag)
                    }
                }

                if vocabSet.modelContext == nil {
                    Section {
                        if !vocabSet.name.isEmpty {
                            Button(Strings.add.localized) {
                                modelContext.insert(vocabSet)
                                dismiss()
                            }
                        }

                        Button(Strings.cancel.localized) {
                            dismiss()
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct VocabSetEditView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()

        if let set = previewContainer.vocabSet {
            VocabSetEditView(vocabSet: set)
                .modelContainer(previewContainer.modelContainer)
        }
    }
}
