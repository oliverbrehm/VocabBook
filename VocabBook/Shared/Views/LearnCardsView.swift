//
//  LearnCardsView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 19.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct LearnCardsView {
    // MARK: - Properties
    let numberOfDueCards: Int
    let coverFrontAction: () -> Void
    let coverBackAction: () -> Void
}

// MARK: - UI
extension LearnCardsView: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Images.lightbulb
                    .foregroundStyle(.orange)

                Text(Strings.learnCards.localized)
                    .bold()

                Spacer()

                Text("\(numberOfDueCards) \(Strings.cardsDue.localized)")
            }

            HStack {
                Spacer()
                Button(Strings.coverFront.localized) { coverFrontAction() }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button(Strings.coverBack.localized) { coverBackAction() }
                    .buttonStyle(.borderedProminent)
                Spacer()
            }
            .bold()
        }
    }
}

// MARK: - Preview
#Preview {
    LearnCardsView(numberOfDueCards: 5, coverFrontAction: {}, coverBackAction: {})
}
