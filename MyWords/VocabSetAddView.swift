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

    // MARK: - Properties

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
}

// MARK: - Actions
extension VocabSetAddView {

}

// MARK: - UI
extension VocabSetAddView {
    var body: some View {
        VStack {
            Text("Add Vocab Set")
                .font(.title)
                .bold()
                .padding()

            Form {
                Section("Name") {
                    TextField(text: $name, label: { Text("Name") })
                }

                Section("Description") {
                    TextField(text: $description, axis: .vertical, label: { Text("Description") })
                }

                Section() {
                    if !name.isEmpty {
                        Button("Add") {
                            modelContext.insert(VocabSet(name: name, descriptionText: description))
                            dismiss()
                        }
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(.gray.opacity(0.1))
    }
}

// MARK: - Preview
struct VocabSetAddView_Previews: PreviewProvider {
    static var previews: some View {
        VocabSetAddView()
            .modelContainer(PreviewContainer().modelContainer)
    }
}
