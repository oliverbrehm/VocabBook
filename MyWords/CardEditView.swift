//
//  CardEditView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI
import SwiftData

struct CardEditView: View {
    // MARK: - Environment

    // MARK: - State

    // MARK: - Properties
    @Bindable var vocabCard: VocabCard

    // MARK: - Functions

    // MARK: - Private properties

    // MARK: - Private functions
}

// MARK: - Actions
extension CardEditView {

}

// MARK: - UI
extension CardEditView {
    var body: some View {
        TabView {
            textInputView(title: "Front", text: $vocabCard.front)
                .tabItem { tabLabel(text: "Front", systemImage: "circle") }

            textInputView(title: "Back", text: $vocabCard.back)
                .tabItem { tabLabel(text: "Back", systemImage: "square") }
        }
    }

    private func tabLabel(text: String, systemImage: String) -> some View {
        VStack {
            Image(systemName: systemImage)
            Text(text)
        }
    }

    private func textInputView(title: String, text: Binding<String>) -> some View {
        VStack {
            TextField("Front", text: text)
            Spacer()
        }
        .padding(20)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        .padding(20)
    }
}

// MARK: - Preview
struct CardEditView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()
        CardEditView(vocabCard: previewContainer.vocabCard)
            .modelContainer(previewContainer.modelContainer)
    }
}
