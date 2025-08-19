//
//  LearnCardsView.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 19.01.24.
//  Copyright © 2024 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct LearnCardsView {
	@AppStorage(UserDefaultsKeys.coverType.rawValue) private var coverType = CoverType.front

    // MARK: - Properties
    let numberOfDueCards: Int
    let coverFrontAction: () -> Void
    let coverBackAction: () -> Void
}

// MARK: - UI
extension LearnCardsView: View {
    var body: some View {
        VStack(spacing: Sizes.marginBig) {
            HStack {
                Images.lightbulb
                    .foregroundStyle(.orange)

                Text(Strings.learnCards.localized)
                    .bold()

                Spacer()

                Text("\(numberOfDueCards) \(Strings.cardsDue.localized)")
            }

            HStack {
                Button(Strings.coverFront.localized) {
					coverType = .front
					coverFrontAction()
				}
				.frame(maxWidth: .infinity)
				.buttonStyle(.borderedProminent)

                Spacer()

				Button(Strings.coverBack.localized) {
					coverType = .back
					coverBackAction()
				}
				.frame(maxWidth: .infinity)
				.buttonStyle(.borderedProminent)
            }
            .bold()
        }
    }
}

// MARK: - Preview
#Preview {
	ZStack {
		LearnCardsView(numberOfDueCards: 5, coverFrontAction: {}, coverBackAction: {})
			.padding()
			.background(.white)
			.padding()
	}
	.background(.gray)
}
