//
//  LanguageSelectView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 26.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct LanguageSelectView {
    // MARK: - State
    @State private var selectedLanugage = Locale.LanguageCode.english
    @State private var selectedRegion = Locale.Region.unitedStates
    @State private var searchLanguage = ""

    // MARK: - Properties
    let vocabSet: VocabSet

    // MARK: - Private functions
    private func updateSet() {
        vocabSet.setLanguage = SetLanguage(
            languageIdentifier: selectedLanugage.identifier,
            regionIdentifier: selectedRegion.identifier
        )
    }

    private var filteredLanguages: [Locale.LanguageCode] {
        if searchLanguage.isEmpty {
            return SetLanguage.allLanguages()
        } else {
            let searchString = searchLanguage.lowercased()
            return SetLanguage.allLanguages()
                .filter { $0.languageString.lowercased().contains(searchString) }
        }
    }
}

// MARK: - UI
extension LanguageSelectView: View {
    var body: some View {
        VStack {
            TextField(Strings.search.localized, text: $searchLanguage)
                .padding(8)
                .background(Color(uiColor: .tertiarySystemBackground))
                .roundedCorners(12)
                .padding(12)

            languageList

            flagList
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(vocabSet.setLanguage.stringWithFlag)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedRegion = vocabSet.setLanguage.region
            selectedLanugage = vocabSet.setLanguage.language
        }
    }

    private var languageList: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredLanguages, id: \.identifier) { language in
                    HStack {
                        if language == selectedLanugage {
                            Images.checkmark
                        }

                        Text(language.languageString)
                            .fontWeight(language == selectedLanugage ? .bold : .regular)

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
        .background(Color(uiColor: .tertiarySystemBackground))
        .roundedCorners(12)
        .padding(12)
    }

    private var flagList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64, maximum: 64))]) {
                ForEach(selectedLanugage.regions, id: \.identifier) { region in
                    HStack {
                        Text(region.emojiFlag ?? "")
                            .font(.system(size: 42))
                            .background(region == selectedRegion ? .blue : .clear)
                            .roundedCorners(6)
                    }
                    .onTapGesture {
                        selectedRegion = region
                        updateSet()
                    }
                }
            }
            .padding(6)
        }
        .background(Color(uiColor: .tertiarySystemBackground))
        .roundedCorners(12)
        .padding(12)
    }
}

// MARK: - Preview
#Preview {
    let previewContainer = PreviewContainer()
    guard let set = previewContainer.vocabSet else { return EmptyView() }

    return NavigationStack {
        LanguageSelectView(vocabSet: set)
    }
    .modelContainer(previewContainer.modelContainer)
}
