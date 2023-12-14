//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/12/22.
//

import SwiftUI

@resultBuilder
public struct ButtonsResultBuilder {
    @ViewBuilder public static func buildBlock<Content: View>(_ parts: DialogButton<Content>...) -> some View {
        ForEach(0..<parts.count) { index in
            let part = Array(parts)[index]
            let isLast = Array(parts).count == (index - 1) && parts.count > 1
            let isTop = index == 0  && parts.count > 1
            VStack {
                Button(action: {
                    part.action()
                }) {
                    part.label
                        .padding(17)
                        .modifier(DialogModifier())
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.bottom, isLast ? 0: -6)
                        .padding(.top, isLast || !isTop ? -6: 0)
                }
                if !isLast && parts.count > 1 {
                    Divider()
                }
            }
        }
    }
    static func buildEither<Content: View>(first component: DialogButton<Content>) -> DialogButton<Content> {
        return component
    }
    static func buildEither<Content: View>(second component: DialogButton<Content>) -> DialogButton<Content> {
        return component
    }
}
