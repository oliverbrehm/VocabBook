//
//  LanguageSelectView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 26.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct LanguageSelectView {
    // MARK: - Environment

    // MARK: - State
    @State var selectedLanugage = Locale.LanguageCode.english
    @State var selectedRegion = Locale.Region.unitedStates
    @State var searchLanguage = ""

    // MARK: - Properties
    let vocabSet: VocabSet

    var filteredLanguages: [Locale.LanguageCode] {
        if searchLanguage.isEmpty {
            return SetLanguage.allLanguages()
        } else {
            let searchString = searchLanguage.lowercased()
            return SetLanguage.allLanguages()
                .filter { $0.languageString.lowercased().contains(searchString) }
        }
    }

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
    private func updateSet() {
        vocabSet.setLanguage = SetLanguage(
            languageIdentifier: selectedLanugage.identifier,
            regionIdentifier: selectedRegion.identifier
        )
    }
}

// MARK: - Actions
extension LanguageSelectView {

}

// MARK: - UI
extension LanguageSelectView: View {
    var body: some View {
        VStack {
            HStack {
                Text(selectedRegion.emojiFlag ?? "")
                Text(selectedLanugage.languageString)
            }

            TextField("Search", text: $searchLanguage)
                .padding(16)

            ScrollView {
                VStack {
                    ForEach(filteredLanguages, id: \.identifier) { language in
                        HStack {
                            if language == selectedLanugage {
                                Image(systemName: "checkmark")
                            }

                            Text(language.languageString)

                            Spacer()
                        }
                        .padding(8)
                        .background(.gray)
                        .onTapGesture {
                            selectedLanugage = language
                            updateSet()
                        }
                        .padding(8)
                    }
                }
            }

            ScrollView {
                VStack {
                    ForEach(SetLanguage.regionsForLanguage(selectedLanugage), id: \.identifier) { region in
                        HStack {
                            if region == selectedRegion {
                                Image(systemName: "checkmark")
                            }

                            Text(region.emojiFlag ?? "")
                                .font(.system(size: 32))
                        }
                        .onTapGesture {
                            selectedRegion = region
                            updateSet()
                        }
                    }
                }
            }
        }
        .onAppear {
            selectedRegion = vocabSet.setLanguage.region
            selectedLanugage = vocabSet.setLanguage.language
        }
    }
}

// MARK: - Preview
#Preview {
    let previewContainer = PreviewContainer()

    guard let set = previewContainer.vocabSet else { return EmptyView() }

    return LanguageSelectView(vocabSet: set)
        .modelContainer(previewContainer.modelContainer)
}
