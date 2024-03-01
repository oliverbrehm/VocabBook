//
//  LanguageSelectView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 26.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import SwiftUI

class LanguageSelectViewModel: ObservableObject {
    // MARK: - Properties
    let vocabSet: VocabSet

    @Published var selectedLanugage = Locale.LanguageCode.english { didSet { updateSet() }}
    @Published var selectedRegion = Locale.Region.unitedStates { didSet { updateSet() }}
    @Published var searchLanguage = ""

    var filteredLanguages: [Locale.LanguageCode] {
        if searchLanguage.isEmpty {
            return SetLanguage.allLanguages
        } else {
            let searchString = searchLanguage.lowercased()
            return SetLanguage.allLanguages
                .filter { $0.languageString.lowercased().contains(searchString) }
        }
    }

    // MARK: - Initializers
    init(vocabSet: VocabSet) {
        self.vocabSet = vocabSet

        selectedRegion = vocabSet.setLanguage.region
        selectedLanugage = vocabSet.setLanguage.language
    }

    // MARK: - Private functions
    private func updateSet() {
        vocabSet.setLanguage = SetLanguage(
            languageIdentifier: selectedLanugage.identifier,
            regionIdentifier: selectedRegion.identifier
        )
    }
}

struct LanguageSelectView: View {
    // MARK: - Environment
    @ObservedObject var viewModel: LanguageSelectViewModel

    // MARK: - UI
    var body: some View {
        VStack(spacing: Sizes.marginDefault) {
            TextField(Strings.search.localized, text: $viewModel.searchLanguage)
                .padding(Sizes.marginDefault)
                .background(Colors.elementBackground)
                .roundedCorners(Sizes.marginDefault)

            languageList

            flagList
        }
        .padding(.horizontal, Sizes.marginDefault)
        .background(Colors.containerBackground)
        .navigationTitle(viewModel.vocabSet.setLanguage.stringWithFlag)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var languageList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.filteredLanguages, id: \.identifier) { language in
                    HStack {
                        if language == viewModel.selectedLanugage {
                            Images.checkmark
                        }

                        Text(language.languageString)
                            .fontWeight(language == viewModel.selectedLanugage ? .bold : .regular)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Sizes.marginSmall)
                    .onTapGesture {
                        viewModel.selectedLanugage = language
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
                ForEach(viewModel.selectedLanugage.regions, id: \.identifier) { region in
                    HStack {
                        Text(region.emojiFlag ?? "")
                            .font(.system(size: Sizes.iconBig))
                            .background(region == viewModel.selectedRegion ? .blue : .clear)
                            .roundedCorners(Sizes.marginSmall)
                    }
                    .onTapGesture {
                        viewModel.selectedRegion = region
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
        LanguageSelectView(viewModel: LanguageSelectViewModel(vocabSet: set))
    }
    .modelContainer(previewContainer.modelContainer)
}
