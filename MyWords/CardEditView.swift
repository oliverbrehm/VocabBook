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
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State var selectedTab = "Front"

    // MARK: - Properties
    @Bindable var vocabCard: VocabCard
    let deleteAction: () -> Void

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
        VStack {
            TabView(selection: $selectedTab) {
                textInputView(title: "Front", text: $vocabCard.front)
                    .tag("Front")

                textInputView(title: "Back", text: $vocabCard.back)
                    .tag("Back")
            }
            .tabViewStyle(.page)
            .padding([.top, .bottom])

            HStack {
                Button(selectedTab, systemImage: "arrow.clockwise.circle.fill") {
                    selectedTab = (selectedTab == "Front" ? "Back" : "Front")
                }

                Spacer()

                Button("", systemImage: "checkmark.circle.fill") {
                    dismiss()
                }

                Spacer()

                Button("Delete", systemImage: "trash.fill") {
                    deleteAction()
                    dismiss()
                }
                .foregroundStyle(.red)
            }
            .padding([.leading, .trailing, .bottom], 32)
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
            TextField("Front", text: text, axis: .vertical)
            Spacer()
        }
        .padding(20)
        .background(.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        .padding([.leading, .trailing])
    }
}

// MARK: - Preview
struct CardEditView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer()
        CardEditView(vocabCard: previewContainer.vocabCard, deleteAction: {})
            .modelContainer(previewContainer.modelContainer)
    }
}
