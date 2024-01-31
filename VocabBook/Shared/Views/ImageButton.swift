//
//  ImageButton.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 04.10.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    let systemName: String
    var size: CGFloat = 32
    
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        })
    }
}
