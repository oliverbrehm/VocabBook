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
            TextField("Search", text: $searchLanguage)
                .padding(8)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(12)

            ScrollView {
                LazyVStack {
                    ForEach(filteredLanguages, id: \.identifier) { language in
                        HStack {
                            if language == selectedLanugage {
                                Image(systemName: "checkmark")
                            }

                            Text(language.languageString)
                                .font(.system(size: 22))

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .onTapGesture {
                            selectedLanugage = language
                            updateSet()
                        }
                    }
                }
                .padding(12)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(12)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64, maximum: 64))]) {
                    ForEach(selectedLanugage.regions, id: \.identifier) { region in
                        HStack {
                            Text(region.emojiFlag ?? "")
                                .font(.system(size: 42))
                                .background(region == selectedRegion ? .blue : .clear)
                        }
                        .onTapGesture {
                            selectedRegion = region
                            updateSet()
                        }
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(vocabSet.setLanguage.stringWithFlag)
        .navigationBarTitleDisplayMode(.inline)
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

    return NavigationStack {
        LanguageSelectView(vocabSet: set)
    }.modelContainer(previewContainer.modelContainer)
}
