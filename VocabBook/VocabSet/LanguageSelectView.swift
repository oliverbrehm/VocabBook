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

    // MARK: - Private properties
    private var filteredLanguages: [Locale.LanguageCode] {
        if searchLanguage.isEmpty {
            return SetLanguage.allLanguages()
        } else {
            let searchString = searchLanguage.lowercased()
            return SetLanguage.allLanguages()
                .filter { $0.languageString.lowercased().contains(searchString) }
        }
    }

    // MARK: - Private functions
    private func updateSet() {
        vocabSet.setLanguage = SetLanguage(
            languageIdentifier: selectedLanugage.identifier,
            regionIdentifier: selectedRegion.identifier
        )
    }
}

// MARK: - UI
extension LanguageSelectView: View {
    var body: some View {
        VStack(spacing: Sizes.marginDefault) {
            TextField(Strings.search.localized, text: $searchLanguage)
                .padding(Sizes.marginDefault)
                .background(Colors.elementBackground)
                .roundedCorners(Sizes.marginDefault)

            languageList

            flagList
        }
        .padding(.horizontal, Sizes.marginDefault)
        .background(Colors.containerBackground)
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
                    .padding(Sizes.marginSmall)
                    .onTapGesture {
                        selectedLanugage = language
                        updateSet()
                    }
                }
            }
            .padding(Sizes.marginDefault)
        }
        .background(Colors.elementBackground)
        .roundedCorners(Sizes.marginDefault)
    }

    private var flagList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Sizes.flagContainer, maximum: Sizes.flagContainer))]) {
                ForEach(selectedLanugage.regions, id: \.identifier) { region in
                    HStack {
                        Text(region.emojiFlag ?? "")
                            .font(.system(size: Sizes.iconBig))
                            .background(region == selectedRegion ? .blue : .clear)
                            .roundedCorners(Sizes.marginSmall)
                    }
                    .onTapGesture {
                        selectedRegion = region
                        updateSet()
                    }
                }
            }
            .padding(Sizes.marginSmall)
        }
        .background(Colors.elementBackground)
        .roundedCorners(Sizes.marginDefault)
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
