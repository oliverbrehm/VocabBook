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

                languages
            }
            .navigationTitle(Strings.editSet.localized)
        }
    }

    private var languages: some View {
        Section("Language") {
            ForEach(getRegions(), id: \.self) { region in
                if let flag = emojiFlag(for: region.identifier), let language = Locale.current.localizedString(forLanguageCode: region.identifier) {
                    Text("\(flag) \(language)")
                }
            }
        }
    }

    private func getRegions() -> [Locale.Region] {
        var regions = Locale.Region.isoRegions
        regions.removeAll { $0.identifier == "QO" }
        return regions
            .sorted { region1, region2 in
                let language1 = Locale.current.localizedString(forLanguageCode: region1.identifier) ?? ""
                let language2 = Locale.current.localizedString(forLanguageCode: region2.identifier) ?? ""
                return language1 < language2
            }
    }

    private func emojiFlag(for regionCode: String) -> String? {
        guard regionCode.count == 2 else { return nil }

        let symbols = regionCode.lowercased().unicodeScalars
            .compactMap { Unicode.Scalar($0.value + (0x1F1E6 - 0x61)) }
            .compactMap { Character($0) }

        return String(symbols)
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
