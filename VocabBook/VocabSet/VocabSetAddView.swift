//
//  VocabSetAddView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct VocabSetAddView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var name = ""
    @State private var description = ""
}

// MARK: - UI
extension VocabSetAddView {
    var body: some View {
        VStack {
            Text(Strings.addVocabSet.localized)
                .font(.title)
                .bold()
                .padding()

            Form {
                Section(Strings.name.localized) {
                    TextField(text: $name, label: { Text(Strings.name.localized) })
                }

                Section(Strings.description.localized) {
                    TextField(text: $description, axis: .vertical, label: { Text(Strings.description.localized) })
                }

                Section {
                    if !name.isEmpty {
                        Button(Strings.add.localized) {
                            modelContext.insert(VocabSet(name: name, descriptionText: description, language: "en", region: ""))
                            dismiss()
                        }
                    }

                    Button(Strings.cancel.localized) {
                        dismiss()
                    }
                    .tint(.red)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Preview
struct VocabSetAddView_Previews: PreviewProvider {
    static var previews: some View {
        VocabSetAddView()
            .modelContainer(PreviewContainer().modelContainer)
    }
}
